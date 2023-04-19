#include "Utils.h"
#include "crossproc.h"
#import "Floating/JFCommon.h"

extern "C" kern_return_t mach_vm_region
(
     vm_map_t target_task,
     mach_vm_address_t *address,
     mach_vm_size_t *size,
     vm_region_flavor_t flavor,
     vm_region_info_t info,
     mach_msg_type_number_t *infoCnt,
     mach_port_t *object_name
 );

extern "C" kern_return_t mach_vm_protect
(
 vm_map_t target_task,
 mach_vm_address_t address,
 mach_vm_size_t size,
 boolean_t set_maximum,
 vm_prot_t new_protection
 );


void Utils::SetTargetPort(task_port_t port){
	targetport = port;
}
task_port_t Utils::GetTargetPort(){
	return targetport;
}
UIViewController* Utils::currentTopViewControllerFn(){
	UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
NSArray* Utils::getRangesList(JSValue* filter){
	if(targetpid!=getpid()){
        //Display(@"Get ranges List Stopped");
        return getRangesList2(targetpid, targetport, [filter isUndefined] ? nil:[filter toString]);
    }
        
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
        
    for(int i=0; i< _dyld_image_count(); i++) {

        const char* name = _dyld_get_image_name(i);
        void* baseaddr = (void*)_dyld_get_image_header(i);
        void* slide = (void*)_dyld_get_image_vmaddr_slide(i); //no use
        
        NSLog(@"getRangesList[%d] %p %p %s", i, baseaddr, slide, name);
        
        if([filter isUndefined]
            || (i==0 && [[filter toString] isEqual:@"0"])
            || [[filter toString] isEqual:[NSString stringWithUTF8String:basename((char*)name) ]]
        ){
            
            uint64_t size = getMachoVMSize(targetpid, targetport, (uint64_t)baseaddr);
            uint64_t end = size ? ((uint64_t)baseaddr+size) : 0;
            
            [results addObject:@{
                @"name" : [NSString stringWithUTF8String:name],
                @"start" : [NSString stringWithFormat:@"0x%llX", baseaddr],
                @"end" : [NSString stringWithFormat:@"0x%llX", end],
                //@"type" : @"rwxp",
            }];
            
            if(i==0 && [[filter toString] isEqual:@"0"]) break;
        }
    }
    
    return results;
}
NSArray* Utils::getProcList(JSValue* filter){
	NSArray* allproc = getRunningProcess();
    if(!allproc)
        return NULL;
    
    NSMutableArray* newarr = [[NSMutableArray alloc] init];
    
    for(NSDictionary* proc in allproc)
    {
        char path[PATH_MAX]={0};
        
        if(!proc_pidpath([[proc valueForKey:@"pid"] intValue], path, sizeof(path)))
            continue;
        
        if(strstr(path, "/private/var/")!=path && strstr(path, "/var/")!=path)
            continue;
        
        if(strstr(path, "/Application/")==NULL)
            continue;
        
        NSLog(@"allproc=%@, %@, %s", [proc valueForKey:@"pid"], [proc valueForKey:@"name"], path);
        
        if([filter isUndefined] || [[filter toString] isEqualToString:[proc valueForKey:@"name"]])
            [newarr addObject:proc];
    }
    return newarr;
}
bool Utils::writeMemory(void* address,void *target, size_t len){
    kern_return_t error = vm_write(targetport, (vm_address_t)address, (vm_offset_t)target, (mach_msg_type_number_t)len);
    if(error != KERN_SUCCESS)
    {
        NSLog(@"writeMemory failed! %p %x", address, len);
        return false;
    }
    
    return true;
}
bool Utils::JJWriteMemory(void* address,void *target, int len){
	mach_port_t object_name;
        mach_vm_size_t region_size=0;
        mach_vm_address_t region_base = (uint64_t)address;
        
        vm_region_basic_info_data_64_t info = {0};
        mach_msg_type_number_t info_cnt = VM_REGION_BASIC_INFO_COUNT_64;
        
        
        kern_return_t kr = mach_vm_region(targetport, &region_base, &region_size,
                                              VM_REGION_BASIC_INFO_64, (vm_region_info_t)&info, &info_cnt, &object_name);
        if(kr != KERN_SUCCESS) {
            NSLog(@"mach_vm_region failed! %p", region_base);
            return false;
        }
        
        vm_address_t base = 0;
        if(!(info.protection & VM_PROT_WRITE)) {
            NSLog(@"unwritable region %p %x : %x", region_base, region_size, info.protection);
            base = (uint64_t)address & ~PAGE_MASK;
            //c1越狱这里可能失败, 不能同时rwx??? c1这里返回成功但是实际上并没有成功!!!!
            kr = mach_vm_protect(targetport, base, PAGE_SIZE, false, info.protection|VM_PROT_WRITE|VM_PROT_COPY);
            if(kr != KERN_SUCCESS) {
                NSLog(@"vm_protect failed! kr=%d [%p %x] : %x", kr, base, PAGE_SIZE, info.protection);
                
                kr = mach_vm_protect(targetport, base, PAGE_SIZE, false, VM_PROT_READ|VM_PROT_WRITE|VM_PROT_COPY);
                if(kr != KERN_SUCCESS) {
                    NSLog(@"vm_protect failed2! kr=%d [%p %x] : %x", kr, base, PAGE_SIZE, info.protection);
                    
                    //NSLog(@"mprotect=%d, %d, %s", mprotect((void*)base, PAGE_SIZE, info.protection|VM_PROT_WRITE), errno, strerror(errno));
                    
                    return false;
                }
            }
        }
        
        bool result = writeMemory(address, target, len);
        
        if(!result && base) {
            
            kr = mach_vm_protect(targetport, base, PAGE_SIZE, false, VM_PROT_READ|VM_PROT_WRITE|VM_PROT_COPY);
            
            if(kr != KERN_SUCCESS) {
                NSLog(@"vm_protect again failed! kr=%d [%p %x] : %x", kr, base, PAGE_SIZE, info.protection);
            } else {
                result = writeMemory(address, target, len);
            }
        }
        
        if(base)
            vm_protect(targetport, base, PAGE_SIZE, false, info.protection);
        
        return result;

}
void Utils::writeFloat(long Address, float value){
	float toWrite = value;
  JJWriteMemory((void*)Address, (void*)&value, 4);
}
bool Utils::IsValidAddress(long addr){
	return addr > 0x100000000 && addr < 0x3000000000;
}
bool Utils::readMem(long addr, void *buffer, int len){
	vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)addr, len, (vm_address_t)buffer, &size);
    if(error != KERN_SUCCESS || size != len)
    {
        return false;
    }
    return true;
}
bool Utils::_read(long addr, void *buffer, int len, task_port_t port){
	if (!IsValidAddress(addr)) return false;
    vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(port, (vm_address_t)addr, len, (vm_address_t)buffer, &size);
    if(error != KERN_SUCCESS || size != len)
    {
        return false;
    }
    return true;
}
template<typename T> T Utils::Read(long address){
	 T data;
    _read(address, reinterpret_cast<void *>(&data), sizeof(T), targetport);
    return data;
}
BOOL Utils::setTargetProc(pid_t pid){
	if(pid==targetpid && targetport!=MACH_PORT_NULL)
        return YES;
    
    if(targetport!=MACH_PORT_NULL && targetport!=mach_task_self())
        mach_port_deallocate(mach_task_self(), targetport);
    
    targetpid = 0;
    targetport = MACH_PORT_NULL;
    
    task_port_t _target_task=0;
    kern_return_t ret = task_for_pid(mach_task_self(), pid, &_target_task);
    NSLog(@"task_for_pid=%d %p %d %s!", pid, ret, _target_task, mach_error_string(ret));
    if(ret==KERN_SUCCESS) {
        targetpid = pid;
        targetport = _target_task;
        return YES;
    }
    
    return NO;
}
long Utils::GetBaseAddr(){
	NSArray* rangesList = getRangesList(0); // assuming filter is already defined
        NSString *startHex = rangesList[0][@"start"];
        unsigned long long nBaseAddr = strtoull([startHex UTF8String], NULL, 16);
        return (long)nBaseAddr;
}
Vector3 Utils::MatrixToVector(FMatrix matrix){
	return Vector3(matrix[3][0], matrix[3][1], matrix[3][2]);
}
FMatrix Utils::MatrixMulti(FMatrix m1, FMatrix m2){
	FMatrix matrix = FMatrix();
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 4; k++) {
                matrix[i][j] += m1[i][k] * m2[k][j];
            }
        }
    }
    return matrix;
}
FMatrix Utils::TransformToMatrix(FTransform transform){
	FMatrix matrix;
    
    matrix[3][0] = transform.Translation.X;
    matrix[3][1] = transform.Translation.Y;
    matrix[3][2] = transform.Translation.Z;
    
    float x2 = transform.Rotation.x + transform.Rotation.x;
    float y2 = transform.Rotation.y + transform.Rotation.y;
    float z2 = transform.Rotation.z + transform.Rotation.z;
    
    float xx2 = transform.Rotation.x * x2;
    float yy2 = transform.Rotation.y * y2;
    float zz2 = transform.Rotation.z * z2;
    
    matrix[0][0] = (1.0f - (yy2 + zz2)) * transform.Scale3D.X;
    matrix[1][1] = (1.0f - (xx2 + zz2)) * transform.Scale3D.Y;
    matrix[2][2] = (1.0f - (xx2 + yy2)) * transform.Scale3D.Z;
    
    float yz2 = transform.Rotation.y * z2;
    float wx2 = transform.Rotation.w * x2;
    matrix[2][1] = (yz2 - wx2) * transform.Scale3D.Z;
    matrix[1][2] = (yz2 + wx2) * transform.Scale3D.Y;
    
    float xy2 = transform.Rotation.x * y2;
    float wz2 = transform.Rotation.w * z2;
    matrix[1][0] = (xy2 - wz2) * transform.Scale3D.Y;
    matrix[0][1] = (xy2 + wz2) * transform.Scale3D.X;
    
    float xz2 = transform.Rotation.x * z2;
    float wy2 = transform.Rotation.w * y2;
    matrix[2][0] = (xz2 + wy2) * transform.Scale3D.Z;
    matrix[0][2] = (xz2 - wy2) * transform.Scale3D.X;
    
    matrix[0][3] = 0;
    matrix[1][3] = 0;
    matrix[2][3] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}
FMatrix Utils::RotatorToMatrix(FRotator rotation){
	float radPitch = rotation.Pitch * ((float) M_PI / 180.0f);
    float radYaw = rotation.Yaw * ((float) M_PI / 180.0f);
    float radRoll = rotation.Roll * ((float) M_PI / 180.0f);
    
    float SP = sinf(radPitch);
    float CP = cosf(radPitch);
    float SY = sinf(radYaw);
    float CY = cosf(radYaw);
    float SR = sinf(radRoll);
    float CR = cosf(radRoll);
    
    FMatrix matrix;
    
    matrix[0][0] = (CP * CY);
    matrix[0][1] = (CP * SY);
    matrix[0][2] = (SP);
    matrix[0][3] = 0;
    
    matrix[1][0] = (SR * SP * CY - CR * SY);
    matrix[1][1] = (SR * SP * SY + CR * CY);
    matrix[1][2] = (-SR * CP);
    matrix[1][3] = 0;
    
    matrix[2][0] = (-(CR * SP * CY + SR * SY));
    matrix[2][1] = (CY * SR - CR * SP * SY);
    matrix[2][2] = (CR * CP);
    matrix[2][3] = 0;
    
    matrix[3][0] = 0;
    matrix[3][1] = 0;
    matrix[3][2] = 0;
    matrix[3][3] = 1;
    
    return matrix;
}
Vector2 Utils::World2Screen(Vector3 worldLocation, FRotator Rotation, Vector3 MyCameraLocation, float fov, int width, int height){
	FMatrix tempMatrix = RotatorToMatrix(Rotation);
    
    Vector3 vAxisX(tempMatrix[0][0], tempMatrix[0][1], tempMatrix[0][2]);
    Vector3 vAxisY(tempMatrix[1][0], tempMatrix[1][1], tempMatrix[1][2]);
    Vector3 vAxisZ(tempMatrix[2][0], tempMatrix[2][1], tempMatrix[2][2]);
    
    Vector3 vDelta = worldLocation - MyCameraLocation;
    
    Vector3 vTransformed(Vector3::Dot(vDelta, vAxisY), Vector3::Dot(vDelta, vAxisZ), Vector3::Dot(vDelta, vAxisX));
    
    if (vTransformed.Z < 1.0f) {
        vTransformed.Z = 1.0f;
    }

    float screenCenterX = (width / 2.0f);
    float screenCenterY = (height / 2.0f);
    
    return Vector2(
                   (screenCenterX + vTransformed.X * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z),
                   (screenCenterY - vTransformed.Y * (screenCenterX / tanf(fov * ((float) M_PI / 360.0f))) / vTransformed.Z)
                   );
}
Vector3 Utils::getBoneWorldPos(long boneTransAddr, FMatrix c2wMatrix){
	FTransform boneTrans = Read<FTransform>(boneTransAddr);
    FMatrix boneMatrix = TransformToMatrix(boneTrans);
    return MatrixToVector(MatrixMulti(boneMatrix, c2wMatrix));
}
Vector3 Utils::GetHeadPos(long Mesh){
	FTransform meshTrans = Read<FTransform>(Mesh + 0x1A0);
    FMatrix c2wMatrix = TransformToMatrix(meshTrans);
    auto boneArray = Read<long>(Mesh + 0x798);
    Vector3 head = getBoneWorldPos(boneArray + 6 * 48, c2wMatrix);//[self getBoneWorldPos:boneArray + 6 * 48 c2wMatrix:c2wMatrix];
    return head;
}
bool Utils::isA(long* Object, long StaticClass){
	if(!IsValidAddress((long)Object)){
        return false;
    }

    if(!IsValidAddress(StaticClass)){
        return false;
    }
    //Read<long>((long)Object + 0x10)
    if ( (Read<int>(StaticClass + 0x90) <= Read<int>(Read<long>((long)Object + 0x10) + 0x90)) 
        && (Read<long>(Read<long>(Read<long>((long)Object + 0x10) + 0x88) + (long)Read<int>(StaticClass + 0x90) * 8) == StaticClass + 0x88)) {
        return true;
    }

    return false;
}
bool Utils::isA(long Object, long StaticClass){
	return isA((long*)Object, StaticClass);
}
uint64_t Utils::GetGWorld(int64_t GWorldData){
	uint64_t uVar1 = 0;
	uint32_t* puVar3 = (uint32_t*)(GWorldData + 0x80);

	for (uint64_t uVar2 = 0; uVar2 != 0x40; uVar2 = uVar2 + 8)
	{
		uVar1 = ((uint64_t)(Read<uint8_t>(GWorldData + static_cast<uint64_t>(Read<uint32_t>((long)puVar3)))) << (uVar2 & 0x3F)) | uVar1;
		puVar3 = puVar3 + 1;
	}

	return Read<long>(uVar1);
}

Vector3 Utils::ReadVec3(long var){
	return Read<Vector3>(var);
}
FRotator Utils::ReadFRotator(long var){
	return Read<FRotator>(var);
}
bool Utils::ReadBool(long var){
	return Read<bool>(var);
}
float Utils::ReadFloat(long var){
	return Read<float>(var);
}

NSArray* Utils::UtilsgetRunningProcess(){
	return getRunningProcess();
}

void Utils::Init(){
	auto var = Read<Vector3>(0x0);
	auto var2 = Read<FRotator>(0x0);
	auto var3 = Read<bool>(0x0);
	auto var4 = Read<float>(0x0);
}


#include <mach-o/dyld.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "Floating/JFCommon.h"
#include "Foundation/Foundation.h"
#include "UIKit/UIKit.h"

class Utils {

	pid_t targetpid;
	task_port_t targetport;


	public:
    static Utils& getInstance() {
        static Utils instance; // The single instance
        return instance;
    }
    UIViewController* currentTopViewControllerFn();
    NSArray* getRangesList(JSValue* filter);
    NSArray* getProcList(JSValue* filter);
    bool writeMemory(void* address,void *target, size_t len);
    bool JJWriteMemory(void* address,void *target, int len);
    void writeFloat(long Address, float value);
    bool IsValidAddress(long addr);
    bool readMem(long addr, void *buffer, int len);
    bool _read(long addr, void *buffer, int len, task_port_t port);
    template<typename T> T Read(long address);
    BOOL setTargetProc(pid_t pid);
    long GetBaseAddr();
    void SetTargetPort(task_port_t port);
    task_port_t GetTargetPort();
    Vector3 MatrixToVector(FMatrix matrix);
    FMatrix MatrixMulti(FMatrix m1, FMatrix m2);
    FMatrix TransformToMatrix(FTransform transform);
    FMatrix RotatorToMatrix(FRotator rotation);
    Vector2 World2Screen(Vector3 worldLocation, FRotator Rotation, Vector3 MyCameraLocation, float fov, int width, int height);
    Vector3 getBoneWorldPos(long base, int index);
    Vector3 getBoneWorldPos(long boneTransAddr, FMatrix c2wMatrix);
    Vector3 GetHeadPos(long Mesh);
    bool isA(long* Object, long StaticClass);
    bool isA(long Object, long StaticClass);
    uint64_t GetGWorld(int64_t GWorldData); //in PUBG turns GWorld Data to the real GName. Its the same as the GWorldFunction
    void Init();
    Vector3 ReadVec3(long var);
    FRotator ReadFRotator(long var);
    bool ReadBool(long var);
    float ReadFloat(long var);
    NSArray* UtilsgetRunningProcess();
};
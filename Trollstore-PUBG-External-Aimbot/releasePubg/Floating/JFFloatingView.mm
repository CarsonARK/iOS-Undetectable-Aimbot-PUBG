
#import "JFFloatingView.h"

@interface JFFloatingView ()

@end

@implementation JFFloatingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = frame.size.width * 0.5;
        self.layer.masksToBounds = YES;
        [self addSubview:self.iconImageView];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapIconView)]];
    }
    return self;
}


- (void)didTapIconView {}

#pragma mark - setter/getter
- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    }
    return _iconImageView;
}

@end

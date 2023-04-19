
#import <UIKit/UIKit.h>
#import "JFDragableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFFloatingView : JFDragableView

@property (nonatomic, strong) UIImageView *iconImageView;

- (void)didTapIconView;

@end

NS_ASSUME_NONNULL_END

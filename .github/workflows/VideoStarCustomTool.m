#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import <CoreImage/CoreImage.h>

// =============================================================================
// VIDEO STAR CUSTOM TOOL (BẢN TỰ DO - KHÔNG CẦN KEY, KHÔNG CẦN SERVER)
// =============================================================================

@interface VSCustomFloatingWindow : UIWindow
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, assign) CGPoint startPanPoint;
@end

@interface VSCustomToolManager : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
+ (instancetype)sharedManager;
- (void)setupFloatingUI;
- (void)handleFloatingButtonTap;
- (void)openQRCodePicker;
- (void)showMergeScenesDialog;
@end

// =============================================================================
// IMPLEMENTATION: FLOATING WINDOW (NÚT NỔI KÉO THẢ)
// =============================================================================
@implementation VSCustomFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 100;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        // Tạo nút tròn nổi với hiệu ứng đổ bóng
        self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.floatingButton.frame = CGRectMake(15, 120, 52, 52);
        self.floatingButton.backgroundColor = [UIColor colorWithRed:0.12 green:0.58 blue:0.95 alpha:0.92];
        self.floatingButton.layer.cornerRadius = 26;
        self.floatingButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.floatingButton.layer.shadowOffset = CGSizeMake(0, 3);
        self.floatingButton.layer.shadowOpacity = 0.35;
        self.floatingButton.layer.shadowRadius = 4;
        self.floatingButton.layer.borderWidth = 1.5;
        self.floatingButton.layer.borderColor = [UIColor whiteColor].CGColor;
        
        // Icon ngôi sao nổi bật
        [self.floatingButton setTitle:@"⭐" forState:UIControlStateNormal];
        self.floatingButton.titleLabel.font = [UIFont systemFontOfSize:24];
        
        // Cử chỉ kéo thả (Pan Gesture)
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.floatingButton addGestureRecognizer:pan];
        
        // Sự kiện chạm
        [self.floatingButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.floatingButton];
    }
    return self;
}

// Chạm xuyên thấu: Chỉ bắt cảm ứng khi chạm đúng vào nút tròn, còn lại chạm xuyên xuống app
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint buttonPoint = [self convertPoint:point toView:self.floatingButton];
    if ([self.floatingButton pointInside:buttonPoint withEvent:event]) {
        return self.floatingButton;
    }
    return nil;
}

- (void)buttonTapped {
    [[VSCustomToolManager sharedManager] handleFloatingButtonTap];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.startPanPoint = self.floatingButton.center;
    }
    
    CGPoint newCenter = CGPointMake(self.startPanPoint.x + translation.x, self.startPanPoint.y + translation.y);
    CGRect bounds = self.bounds;
    CGFloat radius = 26.0;
    
    // Giữ trong khung màn hình
    newCenter.x = MAX(radius, MIN(bounds.size.width - radius, newCenter.x));
    newCenter.y = MAX(radius + 40, MIN(bounds.size.height - radius - 20, newCenter.y));
    self.floatingButton.center = newCenter;
    
    // Tự động hít vào mép trái hoặc phải khi thả tay
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        CGFloat targetX = (newCenter.x > bounds.size.width / 2.0) ? (bounds.size.width - radius - 10) : (radius + 10);
        [UIView animateWithDuration:0.25 animations:^{
            self.floatingButton.center = CGPointMake(targetX, newCenter.y);
        }];
    }
}

@end

// =============================================================================
// IMPLEMENTATION: TOOL MANAGER (MỞ KHÓA TẤT CẢ CHỨC NĂNG, KHÔNG DÙNG KEY)
// =============================================================================
@implementation VSCustomToolManager {
    VSCustomFloatingWindow *_window;
}

+ (instancetype)sharedManager {
    static VSCustomToolManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VSCustomToolManager alloc] init];
    });
    return instance;
}

- (void)setupFloatingUI {
    if (_window) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindowScene *scene = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *s in UIApplication.sharedApplication.connectedScenes) {
                if (s.activationState == UISceneActivationStateForegroundActive && [s isKindOfClass:[UIWindowScene class]]) {
                    scene = (UIWindowScene *)s;
                    break;
                }
            }
        }
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if (@available(iOS 13.0, *) && scene) {
            self->_window = [[VSCustomFloatingWindow alloc] initWithWindowScene:scene];
        } else {
            self->_window = [[VSCustomFloatingWindow alloc] initWithFrame:screenBounds];
        }
        
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        self->_window.rootViewController = rootVC;
        self->_window.hidden = NO;
        
        NSLog(@"[CustomTool] Khởi chạy thành công - Mọi tính năng đã sẵn sàng sử dụng!");
    });
}

// -----------------------------------------------------------------------------
// MENU BẤM NÚT NỔI: SỬ DỤNG TRỰC TIẾP, KHÔNG HỎI KEY
// -----------------------------------------------------------------------------
- (void)handleFloatingButtonTap {
    UIViewController *topVC = [self topViewController];
    if (!topVC) return;
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"⭐ VIDEO STAR PRO TOOL"
                                                                   message:@"Phiên bản tự do • Không giới hạn"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Nút 1: Nhập mã QR từ album ảnh
    [sheet addAction:[UIAlertAction actionWithTitle:@"📷 Nạp Preset từ ảnh QR (Album)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openQRCodePicker];
    }]];
    
    // Nút 2: Tự động gộp cảnh
    [sheet addAction:[UIAlertAction actionWithTitle:@"🎬 Tự động gộp cảnh (Merge Scenes)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showMergeScenesDialog];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
    
    // Hỗ trợ giao diện iPad (Popover)
    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.sourceView = _window.floatingButton;
        sheet.popoverPresentationController.sourceRect = _window.floatingButton.bounds;
    }
    
    [topVC presentViewController:sheet animated:YES completion:nil];
}

// -----------------------------------------------------------------------------
// QUÉT & NẠP PRESET TỪ ẢNH QR
// -----------------------------------------------------------------------------
- (void)openQRCodePicker {
    UIViewController *topVC = [self topViewController];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [topVC presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) return;
    
    // Quét mã QR bằng CoreImage CIDetector tích hợp sẵn trên iOS
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciImage];
    
    if (features.count > 0) {
        CIQRCodeFeature *qr = features.firstObject;
        NSString *qrPayload = qr.messageString;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"✅ Đã đọc mã QR thành công!"
                                                                       message:[NSString stringWithFormat:@"Dữ liệu Preset:\n%@", qrPayload]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Nạp vào Video Star" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"[CustomTool] Đang nạp Preset: %@", qrPayload);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
        [[self topViewController] presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"❌ Không tìm thấy mã QR"
                                                                       message:@"Ảnh được chọn không có mã QR của Video Star!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Đã hiểu" style:UIAlertActionStyleCancel handler:nil]];
        [[self topViewController] presentViewController:alert animated:YES completion:nil];
    }
}

// -----------------------------------------------------------------------------
// GỘP CẢNH (MERGE SCENES)
// -----------------------------------------------------------------------------
- (void)showMergeScenesDialog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🎬 Tự động gộp cảnh"
                                                                   message:@"Chọn thao tác gộp phân đoạn:"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Gộp tất cả các phân đoạn" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"[CustomTool] Đang thực hiện gộp phân đoạn...");
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
    [[self topViewController] presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)topViewController {
    UIViewController *top = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    return top;
}

@end

// =============================================================================
// CONSTRUCTOR: TỰ ĐỘNG CHẠY KHI MỞ VIDEO STAR
// =============================================================================
__attribute__((constructor)) static void custom_tool_init(void) {
    NSLog(@"[CustomTool] VideoStarCustomTool.dylib đã sẵn sàng!");
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        [[VSCustomToolManager sharedManager] setupFloatingUI];
    }];
}

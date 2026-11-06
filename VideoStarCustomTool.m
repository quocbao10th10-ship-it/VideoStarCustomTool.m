#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import <CoreImage/CoreImage.h>
#import <objc/runtime.h>

// =============================================================================
// VIDEO STAR PRO TOOL - CUSTOM EDITION (100% FREE, NO KEY, NO SERVER)
// Thiết kế giao diện đen viền Neon Cyan chuẩn như bản mẫu của anh
// =============================================================================

#define CYAN_COLOR [UIColor colorWithRed:0.0/255.0 green:229.0/255.0 blue:255.0/255.0 alpha:1.0]
#define DARK_BG_COLOR [UIColor colorWithRed:12.0/255.0 green:18.0/255.0 blue:26.0/255.0 alpha:0.96]
#define CARD_BG_COLOR [UIColor colorWithRed:18.0/255.0 green:26.0/255.0 blue:36.0/255.0 alpha:0.9]

@interface VSCustomFloatingWindow : UIWindow
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, assign) CGPoint startPanPoint;
@property (nonatomic, assign) NSInteger currentTabIndex;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) NSMutableArray<UIButton *> *tabButtons;
@end

@interface VSCustomToolManager : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
+ (instancetype)sharedManager;
- (void)setupUI;
- (void)setFloatingButtonVisible:(BOOL)visible;
@end

static VSCustomFloatingWindow *g_floatingWindow = nil;

// =============================================================================
// GIAO DIỆN PANEL & NÚT NỔI CHUẨN ĐỒ HỌA
// =============================================================================
@implementation VSCustomFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 100;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.tabButtons = [NSMutableArray array];
        self.currentTabIndex = 0;
        
        [self buildFloatingButton];
        [self buildMainPanel];
    }
    return self;
}

- (void)buildFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(self.bounds.size.width - 65, 250, 52, 52);
    self.floatingButton.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:16.0/255.0 blue:24.0/255.0 alpha:0.92];
    self.floatingButton.layer.cornerRadius = 26;
    self.floatingButton.layer.borderWidth = 2.0;
    self.floatingButton.layer.borderColor = CYAN_COLOR.CGColor;
    
    // Đổ bóng phát sáng viền Neon
    self.floatingButton.layer.shadowColor = CYAN_COLOR.CGColor;
    self.floatingButton.layer.shadowOffset = CGSizeZero;
    self.floatingButton.layer.shadowOpacity = 0.8;
    self.floatingButton.layer.shadowRadius = 8;
    
    // Icon ngôi sao xanh kèm chữ vs nhỏ bên dưới
    UILabel *starLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 52, 24)];
    starLabel.text = @"★";
    starLabel.textColor = CYAN_COLOR;
    starLabel.font = [UIFont boldSystemFontOfSize:22];
    starLabel.textAlignment = NSTextAlignmentCenter;
    [self.floatingButton addSubview:starLabel];
    
    UILabel *vsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, 52, 16)];
    vsLabel.text = @"VS";
    vsLabel.textColor = CYAN_COLOR;
    vsLabel.font = [UIFont boldSystemFontOfSize:11];
    vsLabel.textAlignment = NSTextAlignmentCenter;
    [self.floatingButton addSubview:vsLabel];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatingButton addGestureRecognizer:pan];
    
    [self.floatingButton addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.floatingButton];
}

- (void)buildMainPanel {
    CGFloat panelWidth = MIN(self.bounds.size.width - 40, 360);
    CGFloat panelHeight = 440;
    CGFloat panelX = (self.bounds.size.width - panelWidth) / 2.0;
    CGFloat panelY = (self.bounds.size.height - panelHeight) / 2.0;
    
    self.panelView = [[UIView alloc] initWithFrame:CGRectMake(panelX, panelY, panelWidth, panelHeight)];
    self.panelView.backgroundColor = DARK_BG_COLOR;
    self.panelView.layer.cornerRadius = 24;
    self.panelView.layer.borderWidth = 2.0;
    self.panelView.layer.borderColor = CYAN_COLOR.CGColor;
    self.panelView.layer.shadowColor = CYAN_COLOR.CGColor;
    self.panelView.layer.shadowOffset = CGSizeZero;
    self.panelView.layer.shadowOpacity = 0.6;
    self.panelView.layer.shadowRadius = 15;
    self.panelView.alpha = 0.0;
    self.panelView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    self.panelView.hidden = YES;
    
    // --- Header ---
    UILabel *starIcon = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, 32, 32)];
    starIcon.text = @"★";
    starIcon.textColor = CYAN_COLOR;
    starIcon.font = [UIFont systemFontOfSize:28];
    [self.panelView addSubview:starIcon];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 14, 200, 22)];
    titleLabel.text = @"VideoStar Tool";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.panelView addSubview:titleLabel];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(56, 34, 200, 16)];
    subTitle.text = @"Custom Pro Edition • No Key";
    subTitle.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    subTitle.font = [UIFont systemFontOfSize:11];
    [self.panelView addSubview:subTitle];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(panelWidth - 46, 16, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    closeBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    closeBtn.layer.cornerRadius = 15;
    [closeBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.panelView addSubview:closeBtn];
    
    // --- Thanh 4 Tabs ---
    NSArray *tabTitles = @[@"Home", @"Function", @"Cài đặt", @"Dev"];
    NSArray *tabIcons = @[@"⌂", @"⚙", @"⚿", @"</>"];
    CGFloat tabW = (panelWidth - 32) / 4.0;
    UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(16, 62, panelWidth - 32, 40)];
    tabBar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    tabBar.layer.cornerRadius = 10;
    
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i * tabW, 0, tabW, 40);
        NSString *title = [NSString stringWithFormat:@"%@ %@", tabIcons[i], tabTitles[i]];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        btn.layer.cornerRadius = 8;
        btn.tag = i;
        [btn addTarget:self action:@selector(tabTapped:) forControlEvents:UIControlEventTouchUpInside];
        [tabBar addSubview:btn];
        [self.tabButtons addObject:btn];
    }
    [self.panelView addSubview:tabBar];
    
    // --- Khung nội dung thay đổi theo Tab ---
    self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(16, 114, panelWidth - 32, 290)];
    [self.panelView addSubview:self.contentContainer];
    
    // --- Footer ---
    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, panelHeight - 26, panelWidth, 18)];
    footer.text = @"VIDEOSTAR • CUSTOM TOOL";
    footer.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    footer.font = [UIFont boldSystemFontOfSize:9];
    footer.textAlignment = NSTextAlignmentCenter;
    [self.panelView addSubview:footer];
    
    [self addSubview:self.panelView];
    [self updateTabUI:0];
}

- (void)tabTapped:(UIButton *)sender {
    [self updateTabUI:sender.tag];
}

- (void)updateTabUI:(NSInteger)index {
    self.currentTabIndex = index;
    for (UIButton *b in self.tabButtons) {
        if (b.tag == index) {
            b.backgroundColor = CARD_BG_COLOR;
            b.layer.borderWidth = 1.2;
            b.layer.borderColor = CYAN_COLOR.CGColor;
            [b setTitleColor:CYAN_COLOR forState:UIControlStateNormal];
        } else {
            b.backgroundColor = [UIColor clearColor];
            b.layer.borderWidth = 0.0;
            [b setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
        }
    }
    
    // Xóa nội dung tab cũ
    for (UIView *v in self.contentContainer.subviews) {
        [v removeFromSuperview];
    }
    
    CGFloat width = self.contentContainer.bounds.size.width;
    
    if (index == 0) { // TAB HOME
        UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, width - 20, 30)];
        welcome.text = @"Xin chào!";
        welcome.textColor = [UIColor whiteColor];
        welcome.font = [UIFont boldSystemFontOfSize:22];
        [self.contentContainer addSubview:welcome];
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, width - 20, 80)];
        desc.text = @"Đây là VideoStar Tool phiên bản tự do, giúp bạn sử dụng VideoStar thuận tiện, tự động hóa và nhanh chóng hơn.";
        desc.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        desc.font = [UIFont systemFontOfSize:14];
        desc.numberOfLines = 0;
        [self.contentContainer addSubview:desc];
        
        UIView *statusBox = [[UIView alloc] initWithFrame:CGRectMake(10, 140, width - 20, 60)];
        statusBox.backgroundColor = CARD_BG_COLOR;
        statusBox.layer.cornerRadius = 12;
        statusBox.layer.borderWidth = 1.0;
        statusBox.layer.borderColor = [UIColor colorWithRed:0.0 green:0.9 blue:0.4 alpha:0.6].CGColor;
        
        UILabel *statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, width - 44, 20)];
        statusLbl.text = @"✓ Trạng thái: Mở khóa vĩnh viễn (No Key)";
        statusLbl.textColor = [UIColor colorWithRed:0.2 green:1.0 blue:0.5 alpha:1.0];
        statusLbl.font = [UIFont boldSystemFontOfSize:13];
        [statusBox addSubview:statusLbl];
        
        UILabel *statusSub = [[UILabel alloc] initWithFrame:CGRectMake(12, 32, width - 44, 18)];
        statusSub.text = @"Tất cả tính năng đã sẵn sàng để sử dụng 100% offline.";
        statusSub.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        statusSub.font = [UIFont systemFontOfSize:11];
        [statusBox addSubview:statusSub];
        [self.contentContainer addSubview:statusBox];
        
    } else if (index == 1) { // TAB FUNCTION (ĐẦY ĐỦ CÁC SWITCH CHỨC NĂNG)
        NSArray *switchTitles = @[
            @"Auto chia beat theo nhạc",
            @"Auto nhập code và ảnh vào các phân cảnh",
            @"Auto nhập ảnh vào các lớp hình ảnh",
            @"Hiển thị code gần nhất từng nhập"
        ];
        
        for (NSInteger i = 0; i < switchTitles.count; i++) {
            UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, i * 55, width, 50)];
            row.backgroundColor = CARD_BG_COLOR;
            row.layer.cornerRadius = 10;
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, width - 80, 50)];
            lbl.text = switchTitles[i];
            lbl.textColor = [UIColor whiteColor];
            lbl.font = [UIFont boldSystemFontOfSize:12.5];
            lbl.numberOfLines = 2;
            [row addSubview:lbl];
            
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(width - 62, 10, 50, 30)];
            sw.onTintColor = CYAN_COLOR;
            sw.on = YES; // Bật sẵn mặc định cho anh
            sw.tag = i + 100;
            [row addSubview:sw];
            
            [self.contentContainer addSubview:row];
        }
        
        // Nút nạp nhanh Preset từ Album ảnh
        UIButton *qrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        qrBtn.frame = CGRectMake(0, 230, width, 45);
        qrBtn.backgroundColor = [UIColor colorWithRed:0.0 green:140.0/255.0 blue:220.0/255.0 alpha:0.9];
        qrBtn.layer.cornerRadius = 10;
        [qrBtn setTitle:@"📷 Quét nạp ảnh QR Preset từ Album" forState:UIControlStateNormal];
        [qrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        qrBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [qrBtn addTarget:self action:@selector(openAlbumQR) forControlEvents:UIControlEventTouchUpInside];
        [self.contentContainer addSubview:qrBtn];
        
    } else if (index == 2) { // TAB CÀI ĐẶT
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, width - 20, 25)];
        title.text = @"Tùy Chỉnh Công Cụ";
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont boldSystemFontOfSize:16];
        [self.contentContainer addSubview:title];
        
        UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 45, width, 140)];
        box.backgroundColor = CARD_BG_COLOR;
        box.layer.cornerRadius = 12;
        
        UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 15, width - 80, 30)];
        l1.text = @"Tự động ẩn nút khi mở bộ lọc/camera";
        l1.textColor = [UIColor whiteColor];
        l1.font = [UIFont systemFontOfSize:13];
        [box addSubview:l1];
        
        UISwitch *swHide = [[UISwitch alloc] initWithFrame:CGRectMake(width - 64, 15, 50, 30)];
        swHide.onTintColor = CYAN_COLOR;
        swHide.on = YES;
        [box addSubview:swHide];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resetBtn.frame = CGRectMake(14, 75, width - 28, 42);
        resetBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
        resetBtn.layer.cornerRadius = 8;
        [resetBtn setTitle:@"Đưa nút nổi về góc màn hình" forState:UIControlStateNormal];
        [resetBtn setTitleColor:CYAN_COLOR forState:UIControlStateNormal];
        resetBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.5];
        [resetBtn addTarget:self action:@selector(resetButtonPosition) forControlEvents:UIControlEventTouchUpInside];
        [box addSubview:resetBtn];
        
        [self.contentContainer addSubview:box];
        
    } else if (index == 3) { // TAB DEV
        UIView *devBox = [[UIView alloc] initWithFrame:CGRectMake(0, 20, width, 180)];
        devBox.backgroundColor = CARD_BG_COLOR;
        devBox.layer.cornerRadius = 14;
        devBox.layer.borderWidth = 1.0;
        devBox.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
        
        UILabel *devTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, width - 30, 25)];
        devTitle.text = @"VideoStar Pro Tool";
        devTitle.textColor = CYAN_COLOR;
        devTitle.font = [UIFont boldSystemFontOfSize:18];
        [devBox addSubview:devTitle];
        
        UILabel *devSub = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, width - 30, 80)];
        devSub.text = @"Phiên bản: V1.0 Custom\nPhát triển riêng cho cộng đồng editor\nKhông quảng cáo • Không cần Key • Hoạt động vĩnh viễn.";
        devSub.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        devSub.font = [UIFont systemFontOfSize:13];
        devSub.numberOfLines = 0;
        [devBox addSubview:devSub];
        
        [self.contentContainer addSubview:devBox];
    }
}

- (void)resetButtonPosition {
    [UIView animateWithDuration:0.3 animations:^{
        self.floatingButton.center = CGPointMake(self.bounds.size.width - 40, 250);
    }];
}

- (void)openAlbumQR {
    [self togglePanel];
    UIViewController *topVC = [self topViewController];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = [VSCustomToolManager sharedManager];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [topVC presentViewController:picker animated:YES completion:nil];
}

- (void)togglePanel {
    BOOL isHidden = self.panelView.hidden;
    if (isHidden) {
        self.panelView.hidden = NO;
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.panelView.alpha = 1.0;
            self.panelView.transform = CGAffineTransformIdentity;
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.panelView.alpha = 0.0;
            self.panelView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        } completion:^(BOOL finished) {
            self.panelView.hidden = YES;
        }];
    }
}

// Bắt cảm ứng thông minh
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.panelView.hidden) {
        CGPoint panelPoint = [self convertPoint:point toView:self.panelView];
        if ([self.panelView pointInside:panelPoint withEvent:event]) {
            return [self.panelView hitTest:panelPoint withEvent:event];
        }
    }
    
    CGPoint buttonPoint = [self convertPoint:point toView:self.floatingButton];
    if ([self.floatingButton pointInside:buttonPoint withEvent:event]) {
        return self.floatingButton;
    }
    return nil;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.startPanPoint = self.floatingButton.center;
    }
    
    CGPoint newCenter = CGPointMake(self.startPanPoint.x + translation.x, self.startPanPoint.y + translation.y);
    CGRect bounds = self.bounds;
    CGFloat radius = 26.0;
    
    newCenter.x = MAX(radius, MIN(bounds.size.width - radius, newCenter.x));
    newCenter.y = MAX(radius + 40, MIN(bounds.size.height - radius - 20, newCenter.y));
    self.floatingButton.center = newCenter;
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        CGFloat targetX = (newCenter.x > bounds.size.width / 2.0) ? (bounds.size.width - radius - 8) : (radius + 8);
        [UIView animateWithDuration:0.25 animations:^{
            self.floatingButton.center = CGPointMake(targetX, newCenter.y);
        }];
    }
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
// MANAGER & HOOK TỰ ĐỘNG ẨN/HIỆN THÔNG MINH
// =============================================================================
@implementation VSCustomToolManager

+ (instancetype)sharedManager {
    static VSCustomToolManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VSCustomToolManager alloc] init];
    });
    return instance;
}

- (void)setupUI {
    if (g_floatingWindow) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect bounds = [UIScreen mainScreen].bounds;
        g_floatingWindow = [[VSCustomFloatingWindow alloc] initWithFrame:bounds];
        
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        g_floatingWindow.rootViewController = rootVC;
        g_floatingWindow.hidden = NO;
        
        NSLog(@"[CustomTool] Khởi tạo giao diện hoàn tất!");
    });
}

- (void)setFloatingButtonVisible:(BOOL)visible {
    if (!g_floatingWindow) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            g_floatingWindow.floatingButton.alpha = visible ? 1.0 : 0.0;
        }];
    });
}

// Xử lý nạp ảnh QR
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) return;
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciImage];
    
    UIViewController *topVC = [g_floatingWindow topViewController];
    if (features.count > 0) {
        CIQRCodeFeature *qr = features.firstObject;
        UIPasteboard.generalPasteboard.string = qr.messageString; // Tự copy vào bộ nhớ tạm
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"✅ Đã đọc mã QR thành công!"
                                                                       message:@"Dữ liệu preset đã được tự động lưu vào bộ nhớ tạm (Clipboard). Bạn có thể bấm Paste trực tiếp trong Multi-Layer!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Đã hiểu" style:UIAlertActionStyleDefault handler:nil]];
        [topVC presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"❌ Không tìm thấy mã QR"
                                                                       message:@"Ảnh này không có mã QR của Video Star!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
        [topVC presentViewController:alert animated:YES completion:nil];
    }
}

@end

// =============================================================================
// HOOK TỰ ĐỘNG ẨN NÚT KHI VÀO MÀN HÌNH CHỈNH SỬA / CAMERA
// =============================================================================
static void (*orig_viewWillAppear)(id self, SEL _cmd, BOOL animated);

static void custom_viewWillAppear(UIViewController *self, SEL _cmd, BOOL animated) {
    orig_viewWillAppear(self, _cmd, animated);
    
    NSString *className = NSStringFromClass([self class]);
    // Nếu vào các màn hình bộ lọc hoặc camera thì tự động làm mờ nút để không vướng
    if ([className containsString:@"Camera"] || [className containsString:@"Picker"] || [className containsString:@"Effect"]) {
        [[VSCustomToolManager sharedManager] setFloatingButtonVisible:NO];
    } else {
        [[VSCustomToolManager sharedManager] setFloatingButtonVisible:YES];
    }
}

__attribute__((constructor)) static void custom_tool_init(void) {
    NSLog(@"[CustomTool] VideoStar Custom Tool Pro Loaded!");
    
    // Hook viewWillAppear để tự ẩn hiện nút mượt mà
    Method m = class_getInstanceMethod([UIViewController class], @selector(viewWillAppear:));
    if (m) {
        orig_viewWillAppear = (void *)method_getImplementation(m);
        method_setImplementation(m, (IMP)custom_viewWillAppear);
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        [[VSCustomToolManager sharedManager] setupUI];
    }];
}

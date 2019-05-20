#import "Tweak.h"
#import <notify.h>

bool moveIntoPanel = false;
MSHConfig *mshConfig;

%group MitsuhaVisuals

%hook SBIconController

%property (retain,nonatomic) MSHView *mshView;

-(void)loadView{
    %orig;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    mshConfig.waveOffsetOffset = bounds.size.height - 200;

    if (![mshConfig view]) [mshConfig initializeViewWithFrame:self.view.bounds];
    self.mshView = [mshConfig view];
    
    [self.view addSubview:self.mshView];
    [self.view sendSubviewToBack:self.mshView];
}

-(void)viewWillAppear:(BOOL)animated{
    %orig;
    [self.mshView start];
}

-(void)viewWillDisappear:(BOOL)animated{
    %orig;
    [self.mshView stop];
}

%end

%end

static void screenDisplayStatus(CFNotificationCenterRef center, void* o, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
    uint64_t state;
    int token;
    notify_register_check("com.apple.iokit.hid.displayStatus", &token);
    notify_get_state(token, &state);
    notify_cancel(token);
    if ([mshConfig view]) {
        if (state) {
            [[mshConfig view] start];
        } else {
            [[mshConfig view] stop];
        }
    }
}

%ctor{
    mshConfig = [MSHConfig loadConfigForApplication:@"HomeScreen"];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)screenDisplayStatus, (CFStringRef)@"com.apple.iokit.hid.displayStatus", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    %init(MitsuhaVisuals);
}

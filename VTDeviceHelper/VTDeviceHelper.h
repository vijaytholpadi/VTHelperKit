//
//  VTDeviceHelper.h
//  TheGeekProjekt
//
//  Created by Vijay Tholpadi on 6/2/15.
//  Copyright (c) 2015 TheGeekProjekt. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Logging

static inline void DLog(NSString *format, ...) {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
#endif
}

#pragma mark - Colors

static inline UIColor * RGBA(int r, int g, int b, float a) {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

static inline UIColor * RGB(int r, int g, int b) {
    return RGBA(r, g, b, 1.0);
}

#pragma mark - Device

static inline BOOL iPhoneDevice() {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

static const int iPhone6PScreenHeight = 736;
static inline BOOL iPhone6PScreen() {
    return ([[UIScreen mainScreen] bounds].size.height == iPhone6PScreenHeight);
}

static const int iPhone6ScreenHeight = 667;
static inline BOOL iPhone6Screen() {
    return ([[UIScreen mainScreen] bounds].size.height == iPhone6ScreenHeight);
}

static const int iPhone5ScreenHeight = 568;
static inline BOOL iPhone5Screen() {
    return ([[UIScreen mainScreen] bounds].size.height == iPhone5ScreenHeight);
}

static const int iPhone4ScreenHeight = 480;
static inline BOOL iPhone4Screen() {
    return ([[UIScreen mainScreen] bounds].size.height == iPhone4ScreenHeight);
}

static inline BOOL iPhone5ScreenOrBigger() {
    return ([[UIScreen mainScreen] bounds].size.height >= iPhone5ScreenHeight);
}

static inline BOOL iOS7Device() {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0);
}

static inline BOOL iOS8Device() {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
}

#pragma mark - Determine device resolution
static inline NSString* deviceResolution() {
    NSString *resolution = @"hdpi";
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);

    if ((screenSize.height == 480) && (screenSize.width == 320)) {
        resolution = @"mdpi";
    }else if ((screenSize.height == 960) && (screenSize.width == 640)) {
        resolution = @"hdpi";
    }else if ((screenSize.height == 1136) && (screenSize.width == 640)) {
        resolution = @"hdpi";
    }else if ((screenSize.height == 1334) && (screenSize.width == 750)) {
        resolution = @"xhdpi";
    }else if ((screenSize.height == 2208) && (screenSize.width == 1242)) {
        resolution = @"xxhdpi";
    }
    return resolution;
}

#pragma mark - User Defaults

static inline void saveDefaults() {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline id defaultsValue(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

static inline void setDefaultsValueSaving(NSString *key, id value, BOOL save) {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    if (save) {
        saveDefaults();
    }
}

static inline void setDefaultsValue(NSString *key, id value) {
    setDefaultsValueSaving(key, value, NO);
}

#pragma mark - Notifications

static inline void addNotificationObserverWithObject(id observer, SEL selector, NSString *notificationName, id object) {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:notificationName object:object];
}

static inline void addNotificationObserver(id observer, SEL selector, NSString *notificationName) {
    addNotificationObserverWithObject(observer, selector, notificationName, nil);
}

static inline void postNotificationWithObjectAndInfo(NSString *notificationName, id object, NSDictionary *info) {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object userInfo:info];
}

static inline void postNotification(NSString *notificationName) {
    postNotificationWithObjectAndInfo(notificationName, nil, nil);
}

static inline void removeNotificationObserver(id observer) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

#pragma mark - Alert View

static inline void showAlertWithTitleAndDelegate(NSString *title, NSString *message, id delegate) {
    if (iOS8Device()) {
        NSString *titleString = title ? title : @"";
        NSString *messageString = title ? message : [NSString stringWithFormat:@"%@", message];
        [[[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

static inline void showAlert(NSString *message) {
    if (!message) {
        return;
    }
    showAlertWithTitleAndDelegate(nil, message, nil);
}

#define UltraBoldFontLato(_size_) [UIFont fontWithName:@"Lato-Black" size:_size_ / 1.95]
#define BoldFontLato(_size_) [UIFont fontWithName:@"Lato-Bold" size:_size_ / 1.95]
#define NormalFontLato(_size_) [UIFont fontWithName:@"Lato-Regular" size:_size_ / 1.95]
#define LightFontLato(_size_) [UIFont fontWithName:@"Lato-Light" size:_size_ / 1.95]
#define ThinFontLato(_size_) [UIFont fontWithName:@"Lato-Hairline" size:_size_ / 1.95]
#define UltraBoldItalicFontLato(_size_) [UIFont fontWithName:@"Lato-BlackItalic" size:_size_ / 1.95]
#define BoldItalicFontLato(_size_) [UIFont fontWithName:@"Lato-BoldItalic" size:_size_ / 1.95]
#define NormalItalicFontLato(_size_) [UIFont fontWithName:@"Lato-Italic" size:_size_ / 1.95]
#define LightItalicFontLato(_size_) [UIFont fontWithName:@"Lato-LightItalic" size:_size_ / 1.95]
#define ThinItalicFontLato(_size_) [UIFont fontWithName:@"Lato-HairlineItalic" size:_size_ / 1.95]

#define UltraBoldFont(_size_) [UIFont fontWithName:@"HelveticaNeue-Bold" size:_size_ / 1.95]
#define BoldFont(_size_) [UIFont fontWithName:@"HelveticaNeue-Bold" size:_size_ / 1.95]
#define NormalFont(_size_) [UIFont fontWithName:@"HelveticaNeue" size:_size_ / 1.95]
#define LightFont(_size_) [UIFont fontWithName:@"HelveticaNeue-Light" size:_size_ / 1.95]
#define ThinFont(_size_) [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:_size_ / 1.95]
#define UltraBoldItalicFont(_size_) [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:_size_ / 1.95]
#define BoldItalicFont(_size_) [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:_size_ / 1.95]
#define NormalItalicFont(_size_) [UIFont fontWithName:@"HelveticaNeue-Italic" size:_size_ / 1.95]
#define LightItalicFont(_size_) [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:_size_ / 1.95]
#define ThinItalicFont(_size_) [UIFont fontWithName:@"HelveticaNeue-UltraLightItalic" size:_size_ / 1.95]

#pragma mark - Other

static inline UIStoryboard * Storyboard() {
    return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
}

static inline BOOL notNull(id value) {
    return ![value isKindOfClass:[NSNull class]];
}

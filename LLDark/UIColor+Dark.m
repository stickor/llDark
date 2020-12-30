//
//  UIColor+Dark.m
//  LLDark
//
//  Created by LL on 2020/11/17.
//

#import "UIColor+Dark.h"

#import "LLDarkSource.h"
#import "LLDarkManager.h"
#import "LLDarkDefine.h"

#import <objc/runtime.h>

static char * const ll_theme_lightColor_identifier = "ll_theme_lightColor_identifier";
static char * const ll_theme_darkColor_identifier = "ll_theme_darkColor_identifier";

@interface UIColor ()

/// 浅色主题颜色
@property (nonatomic) UIColor *lightColor;

/// 深色主题颜色
@property (nonatomic) UIColor *darkColor;

@end

@implementation UIColor (Dark)

- (UIColor *)removeTheme {
    if (!self.isTheme) return self;
    return self.lightColor.deepColor;
}

- (UIColor * _Nonnull (^)(UIColor * _Nullable))themeColor {
    return ^(UIColor * _Nullable darkColor) {
        UIColor *lightColor = self;
        if (self.isTheme) lightColor = self.lightColor;
        
        if (!darkColor) darkColor = self.darkColor;
        if (!darkColor) darkColor = LLDarkSource.darkColorForKey(lightColor);
        
        return UIColor.dynamicThemeColor(lightColor, darkColor);
    };
}

- (UIColor * _Nonnull (^)(void))themeAutoColor {
    return ^(void){
        UIColor *lightColor = self;
        if (self.isTheme) lightColor = self.lightColor;
        
        UIColor * _Nullable darkColor = LLDarkSource.darkColorForKey(lightColor);
        
        return UIColor.dynamicThemeColor(lightColor, darkColor);
    };
    
}

- (CGColorRef _Nonnull (^)(UIColor * _Nullable))themeCGColor {
    return ^(UIColor * _Nullable darkColor) {
        return (__bridge CGColorRef)self.themeColor(darkColor);
    };
}

- (CGColorRef  _Nonnull (^)(void))themeAutoCGColor {
    return ^(void) {
        return (__bridge CGColorRef)self.themeAutoColor();
    };
}

+ (UIColor * (^) (UIColor *lightColor, UIColor * _Nullable darkColor))dynamicThemeColor {
    return ^(UIColor *lightColor, UIColor * _Nullable darkColor) {
        
        if (!darkColor) return (UIColor *)lightColor;
        
        lightColor = lightColor.deepColor;
        darkColor = darkColor.deepColor;
        
        lightColor.lightColor = lightColor;
        lightColor.darkColor = darkColor;
        
        darkColor.lightColor = lightColor;
        darkColor.darkColor = darkColor;
        
        return (UIColor *)correctObj(lightColor, darkColor);
    };
}

#pragma mark - setter/getter
- (void)setLightColor:(UIColor *)lightColor {
    objc_setAssociatedObject(self, ll_theme_lightColor_identifier, lightColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)lightColor {
    return objc_getAssociatedObject(self, ll_theme_lightColor_identifier);
}

- (void)setDarkColor:(UIColor * _Nonnull)darkColor {
    objc_setAssociatedObject(self, ll_theme_darkColor_identifier, darkColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)darkColor {
    return objc_getAssociatedObject(self, ll_theme_darkColor_identifier);
}

- (BOOL)isTheme {
    return (self.lightColor != nil);
}

- (UIColor * _Nonnull (^)(LLUserInterfaceStyle))resolvedColor {
    return ^(LLUserInterfaceStyle userInterfaceStyle) {
        if (userInterfaceStyle == LLUserInterfaceStyleUnspecified) {
            return correctObj(self.lightColor, self.darkColor);
        } else if (userInterfaceStyle == LLUserInterfaceStyleLight) {
            return (id)self.lightColor;
        } else {
            return (id)self.darkColor;
        }
    };
}

- (CGColorRef _Nonnull (^)(LLUserInterfaceStyle))resolvedCGColor {
    return ^(LLUserInterfaceStyle userInterfaceStyle) {
        return (__bridge CGColorRef)self.resolvedColor(userInterfaceStyle);
    };
}

- (UIColor *)deepColor {
    return [UIColor colorWithCGColor:self.CGColor];
}

@end

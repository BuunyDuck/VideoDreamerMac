//
//  SilentBridge.m
//  VideoDreamer
//
//  Created by Yinjing Li on 2/21/23.
//

#import "SilentBridge.h"

@interface NSObject(SilentBridge)

- (id)standardWindowButton:(NSInteger)value;
- (void)setEnabled:(BOOL)flag;

@end

@implementation SilentBridge

+ (void)disableCloseButtonFor:(NSObject *)window {
    if ([window respondsToSelector:@selector(standardWindowButton:)]) {
        id closeButton = [window standardWindowButton:2];
        if ([closeButton respondsToSelector:@selector(setEnabled:)]) {
            [closeButton setEnabled:NO];
        }
    }
}

@end

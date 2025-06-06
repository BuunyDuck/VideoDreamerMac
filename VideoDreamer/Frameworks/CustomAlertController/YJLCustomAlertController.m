//
//  YJLCustomAlertController.m
//  RandomMusicPlayer
//
//  Created by APPLE on 8/23/18.
//  Copyright © 2018 Yinjing Li. All rights reserved.
//

#import "YJLCustomAlertController.h"

@implementation YJLCustomAlertController

-(id) initObject
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

-(void) setTitle:(NSString*) title message:(NSString*) message
{
    CGFloat fTitleFontSize = 20.0f;
    CGFloat fMessageFontSize = 18.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        fTitleFontSize = 25.0f;
        fMessageFontSize = 22.0f;
    }
    
    
    self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    // title color
    NSMutableAttributedString *titleAttributed = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange matchRange = NSMakeRange(0, title.length);
    [titleAttributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Semibold" size:fTitleFontSize] range:matchRange];
    [titleAttributed addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:matchRange];
    [self.alertController setValue:titleAttributed forKey:@"attributedTitle"];
    
    
    // message color
    NSMutableAttributedString *messageAttributed = [[NSMutableAttributedString alloc] initWithString:message];
    matchRange = NSMakeRange(0, message.length);
    [messageAttributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"MyriadPro-Semibold" size:fMessageFontSize] range:matchRange];
    [messageAttributed addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:matchRange];
    [self.alertController setValue:messageAttributed forKey:@"attributedMessage"];
    
    
    // background color, corner radius, border with, border color
    UIView* v = self.alertController.view.subviews.firstObject;
    
    if ([v isKindOfClass:[UIView class]])
    {
        UIView* actionView = v.subviews.firstObject;
        
        for (UIView* innerView in actionView.subviews)
        {
            innerView.backgroundColor = [UIColor blackColor];
            innerView.layer.borderColor = [UIColor redColor].CGColor;
            innerView.layer.borderWidth = 1.0f;
            innerView.layer.cornerRadius = 15.0;
            innerView.clipsToBounds = true;
        }
    }
    
    
    self.alertController.view.tintColor = [UIColor greenColor];
}


@end

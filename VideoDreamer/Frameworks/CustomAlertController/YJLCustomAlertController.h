//
//  YJLCustomAlertController.h
//  RandomMusicPlayer
//
//  Created by APPLE on 8/23/18.
//  Copyright © 2018 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YJLCustomAlertController : NSObject

@property(nonatomic, strong) UIAlertController* alertController;

-(void) setTitle:(NSString*) title message:(NSString*) message;

@end

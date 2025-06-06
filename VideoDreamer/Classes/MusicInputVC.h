//
//  MusicInputVC.h
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import "YJLCustomAlertController.h"

@class Music;
@class MusicDownload;
@class ProjectManager;
@class TimelineView;

@protocol MusicInputVCDelegate;

@interface MusicInputVC : UIViewController<NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, UITextFieldDelegate, NSObject>
{
   Music *music;
   NSString * imagePath;
}

@property(nonatomic, weak) MusicDownload* musicDownload;
@property(nonatomic, strong) ProjectManager* projectManager;
@property(nonatomic, strong) TimelineView* timelineView;
@property(nonatomic, retain) Music *music;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) IBOutlet UITextField *notesTextField;

@property(nonatomic, strong) NSMutableArray* mediaObjectArray;
@property(nonatomic, strong) NSMutableArray* editThumbnailArray;

@property (nonatomic, strong) UINavigationController *navigationController;

@end

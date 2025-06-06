//
//  MusicCell.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicCellDelegate;

@protocol MusicCellDelegate <NSObject>

- (void)changedMusicName;
- (void)selectedPlayIndex:(NSInteger) nIndex isPlayingStatus:(BOOL) playing;

@end

@interface MusicCell : UITableViewCell <UITextFieldDelegate>

@property(nonatomic, retain) id <MusicCellDelegate> delegate;

@property(nonatomic, retain) UILabel* titleLabel;
@property(nonatomic, retain) UITextField* nameTextField;

@property(nonatomic, retain) UIButton* playButton;

@property(nonatomic, retain) NSString* folderName;
@property(nonatomic, retain) NSString* originalName;

@property(nonatomic, assign) NSInteger nIndex;
@property(nonatomic, assign) BOOL isPlaying;


-(void) setPlaybuttonStatus:(BOOL) playing;


@end

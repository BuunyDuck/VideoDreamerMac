//
//  LaunchVC.h
//  RandomMusicPlayer
//
//  Created by APPLE on 11/27/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Music : NSObject <NSSecureCoding>
{
    NSString *name;
    NSString *url;
    NSString *login;
    NSString *notes;
    NSString *image;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *login;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSString *image;

- (id)initWithName:(NSString *)name url:(NSString *)url;
- (id)initWithName:(NSString *)name url:(NSString *)url login:(NSString *)login notes:(NSString *)notes image:(NSString *)image;

@end

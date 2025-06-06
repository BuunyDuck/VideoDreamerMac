//
//  LaunchVC.m
//  RandomMusicPlayer
//
//  Created by APPLE on 11/27/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "Music.h"
@implementation Music
@synthesize name;
@synthesize url;
@synthesize login;
@synthesize notes;
@synthesize image;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.login forKey:@"login"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
    [aCoder encodeObject:self.image forKey:@"image"];
}

- (id)initWithName:(NSString *)name url:(NSString *)url {
    self = [super init];
    if (self) {
        self.name = name;
        self.url = url;
        self.login = @"";
        self.notes = @"";
        self.image = @"";
    }
    return self;
}

- (id)initWithName:(NSString *)name url:(NSString *)url login:(NSString *)login notes:(NSString *)notes image:(NSString *)image {
    self = [super init];
    if (self) {
        self.name = name;
        self.url = url;
        self.login = login;
        self.notes = notes;
        self.image = image;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.login = [aDecoder decodeObjectForKey:@"login"];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

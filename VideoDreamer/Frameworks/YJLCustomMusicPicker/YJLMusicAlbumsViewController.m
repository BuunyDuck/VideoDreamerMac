//
//  YJLMusicAlbumsViewController.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLMusicAlbumsViewController.h"
#import "YJLCustomMusicController.h"
#import "MusicCell.h"
#import "YJLActionMenu.h"
#import "SceneDelegate.h"

#define PLAYLISTS 0
#define ARTISTS 1
#define SONGS 2
#define ALBUMS 3
#define GENRES 4
#define LIBRARY 5


@interface YJLMusicAlbumsViewController ()  <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, MusicCellDelegate>
{
    IBOutlet UIView *containersView;
    
    BOOL _fetchedFirstTime;
    BOOL sortByDuration;

    NSInteger collectionSelectedIndex;
    
    UIActivityIndicatorView *_indicatorView;
    
    NSArray* collectionsArray;
    NSArray* songsArray;
    NSMutableArray* musicArray;
    NSString *folderName;
    
    BOOL isFirstLayout;
}

@end


@implementation YJLMusicAlbumsViewController

@synthesize customMusicController = _customMusicController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if ([UIScreen mainScreen].nativeBounds.size.height == 2001) // iphone x
            self.tabbarHeightConstraint.constant = 83.0f;
    }
    
    UITabBarItem *appearance = [UITabBarItem appearance];
    [appearance setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Regular" size:[UIFont systemFontSize]]} forState:UIControlStateNormal];
    
    isFirstLayout = YES;

    self.customMusicController = (YJLCustomMusicController*)self.navigationController;

    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL fromDownload = [userDefaults boolForKey:@"fromDownload"];
    
    sortByDuration = YES;
    isEdit = NO;
    isPlaying = NO;
    nPlayingIndex = -1;
    folderName = @"Library";
    
    [self _processMusicLoader];
    [self _configureMusicFolder];
    [self _configureMusicLoader];
    
    if (fromDownload == NO) {
        [self requestAuthorization:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    self->collectionSelectedIndex = PLAYLISTS;
                    [self _configureAlbumsLoader:PLAYLISTS];
                    self.title = NSLocalizedString(@"Playlists", nil);
                } else {
                    
                }
                [self _configureNavigationBarButtons];
                [self _setupViews];
                [self.collectionTableView reloadData];
            });
        }];
    } else {
        collectionSelectedIndex = LIBRARY;
        self.title = NSLocalizedString(@"Library", nil);
        [self _configureNavigationBarButtons];
        [self _setupViews];
        [self.collectionTableView reloadData];
        [self tableView:self.collectionTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)requestAuthorization:(void(^)(BOOL))completion {
    if ([MPMediaLibrary authorizationStatus] == MPMediaLibraryAuthorizationStatusDenied) {
        completion(NO);
    } else {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                completion(YES);
            } else {
                completion(NO);
            }
        }];
    }
}

- (void)_configureNavigationBarButtons
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onDidCancel)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:MYRIADPRO size:16.0f], NSFontAttributeName, [UIColor darkGrayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateHighlighted];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    self.navigationItem.leftBarButtonItem.tag = 1;
}

- (void)_configureRightButton
{
    _sortButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20 , 20)];
    [_sortButton setImage:[UIImage imageNamed:@"sort_down"] forState:UIControlStateNormal];
    [_sortButton addTarget:self action:@selector(onShowSortMenu:) forControlEvents:UIControlEventTouchUpInside];
    _sortButton.tag = 1;

    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithCustomView:_sortButton];
    [self.navigationItem setRightBarButtonItem:sortButton];

    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlaybackDuration
                                                             ascending:YES];
    NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
    songsArray = [NSArray arrayWithArray:sortedSongsArray];
}

-(void) _configureEditButton
{
    _editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50 , 20)];
    [_editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_editButton setBackgroundColor:[UIColor clearColor]];
    [_editButton addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
    _editButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:16.0];
    _editButton.tag = 1;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:_editButton];
    [self.navigationItem setRightBarButtonItem:editButton];
    
    if (musicArray.count == 0)
    {
        _editButton.enabled = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (isFirstLayout == YES) {
        isFirstLayout = NO;
        
        _collectionTableView.frame = containersView.bounds;
        CGRect frame = containersView.bounds;
        frame.origin.x = _musicTableView.frame.origin.x;
        _musicTableView.frame = frame;
        if (@available(iOS 15.0, *)) {
            _collectionTableView.sectionHeaderTopPadding = 0.0;
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)_setupViews
{
    [_albumsTabbar setTintColor:[UIColor redColor]];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL fromDownload = [userDefaults boolForKey:@"fromDownload"];
    
    if (fromDownload == NO) {
        [_albumsTabbar setSelectedItem:self.playlistsItem];
        
        /* table */
        _collectionTableView = [self newTableView];
        [containersView addSubview:_collectionTableView];
        _collectionTableView.tag = 0;
    } else {
        [_albumsTabbar setSelectedItem:self.libraryItem];
        
        /* table */
        _collectionTableView = [self newTableView];
        [containersView addSubview:_collectionTableView];
         _collectionTableView.tag = 0;
    }
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    _collectionTableView.backgroundView = imageView;

    _musicTableView = [self newTableView];
    [containersView addSubview:_musicTableView];
    CGFloat max = self.view.frame.size.width >= self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height;
    _musicTableView.frame = CGRectMake(max, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
    _musicTableView.tag = 1;
    _musicTableView.hidden = YES;
    
    UIImageView* imageView_ = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView_ setImage:[UIImage imageNamed:@"specialistEditBg"]];
    _musicTableView.backgroundView = imageView_;
    [self.view bringSubviewToFront:_albumsTabbar];
}

- (UITableView *)newTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:containersView.bounds style:UITableViewStylePlain];
    [tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    tableView.sectionHeaderHeight = 0.0;
    if (@available(iOS 15.0, *)) {
        tableView.sectionHeaderTopPadding = 0.0;
    } else {
        // Fallback on earlier versions
    }
    
    return tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_collectionTableView setNeedsLayout];
    [_collectionTableView setNeedsDisplay];
    [_collectionTableView reloadData];

    [_musicTableView setNeedsLayout];
    [_musicTableView setNeedsDisplay];
    [_musicTableView reloadData];
}


#pragma mark -
#pragma mark - Actions

- (void)onDidCancel
{
    isPlaying = NO;
    nPlayingIndex = -1;
    
    if (self.songPlayer)
        [self.songPlayer pause];

    if (self.navigationItem.leftBarButtonItem.tag == 1)
    {
        if ([self.customMusicController.customMusicDelegate respondsToSelector:@selector(musicPickerControllerDidCancel:)]) {
            [self.customMusicController.customMusicDelegate musicPickerControllerDidCancel:self.customMusicController];
        }
    }
    else if (self.navigationItem.leftBarButtonItem.tag == 2)
    {
        [self _configureAlbumsLoader:collectionSelectedIndex];
        [_collectionTableView reloadData];

        self.navigationItem.leftBarButtonItem.tag = 1;
        [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"Cancel", nil)];
        self.title = self.albumsTabbar.selectedItem.title;
        
        self.navigationItem.rightBarButtonItem = nil;
        
        [UIView animateWithDuration:0.2f animations:^{
            CGFloat max = self.view.frame.size.width >= self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height;
            self.musicTableView.frame = CGRectMake(max, self.musicTableView.frame.origin.y, self.musicTableView.frame.size.width, self.musicTableView.frame.size.height);
        } completion:^(BOOL finished) {
            self.musicTableView.hidden = YES;
            self.collectionTableView.userInteractionEnabled = YES;
        }];
    }
}

- (void)onShowSortMenu:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Sort by duration", nil)
                     image:nil
                    target:self
                    action:@selector(onSortByDuration)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Sort by alphabetical", nil)
                     image:nil
                    target:self
                    action:@selector(onSortByAlphabetical)],
      ];
    
    
    CGRect frame = [_sortButton convertRect:_sortButton.bounds toView:self.navigationController.view];
    [YJLActionMenu showMenuInView:self.navigationController.view
                  fromRect:frame
                 menuItems:menuItems isWhiteBG:NO];
}

- (void)onSortByDuration
{
    if (_sortButton.tag == 1)
    {
        _sortButton.tag = 2;
        [_sortButton setImage:[UIImage imageNamed:@"sort_up"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlaybackDuration
                                                                 ascending:NO];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];
        
        [_musicTableView reloadData];
    }
    else if (_sortButton.tag == 2)
    {
        _sortButton.tag = 1;
        [_sortButton setImage:[UIImage imageNamed:@"sort_down"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlaybackDuration
                                                                 ascending:YES];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];

        [_musicTableView reloadData];
    }
}

- (void)onSortByAlphabetical
{
    if (_sortButton.tag == 1)
    {
        _sortButton.tag = 2;
        [_sortButton setImage:[UIImage imageNamed:@"sort_up"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyTitle
                                                                 ascending:NO];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];
        
        [_musicTableView reloadData];
    }
    else if (_sortButton.tag == 2)
    {
        _sortButton.tag = 1;
        [_sortButton setImage:[UIImage imageNamed:@"sort_down"] forState:UIControlStateNormal];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyTitle
                                                                 ascending:YES];
        NSArray *sortedSongsArray = [songsArray sortedArrayUsingDescriptors:@[sorter]];
        songsArray = [NSArray arrayWithArray:sortedSongsArray];
        
        [_musicTableView reloadData];
    }
}

-(void) onEdit:(id) sender
{
    if ([sender tag] == 1)
    {
        if (musicArray.count > 0)
        {
            isEdit = YES;
            
            [_editButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            _editButton.tag = 2;
            
            [_musicTableView setEditing:YES animated:YES];
        }
    }
    else if ([sender tag] == 2)
    {
        isEdit = NO;
        
        [_editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
        _editButton.tag = 1;
        
        [_musicTableView setEditing:NO animated:YES];
    }
    
    [_musicTableView reloadData];
}


#pragma mark -
#pragma mark - Configuration

- (void)_configureAlbumsLoader:(NSInteger) index
{
    MPMediaQuery* query = nil;
    collectionsArray = nil;
    
    switch (index)
    {
        case PLAYLISTS:
        {
            query = [MPMediaQuery playlistsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            
            NSArray* tempArray = [query collections];
            NSMutableArray* tempPlaylistArray = [[NSMutableArray alloc] init];

            for (int i = 0; i < tempArray.count; i++) {
                MPMediaPlaylist* playlist = [tempArray objectAtIndex:i];
                NSString* collectionName = [playlist valueForProperty:MPMediaPlaylistPropertyName];
                
                if (([collectionName isEqualToString:@"Purchased"]) || ([collectionName isEqualToString:@"Playback History"]))
                    continue;
                
                [tempPlaylistArray addObject:playlist];
            }
            
            collectionsArray = [NSArray arrayWithArray:tempPlaylistArray];
            break;
        }
        case ARTISTS:
            query = [MPMediaQuery artistsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query collections];
            break;
        case SONGS:
            query = [MPMediaQuery songsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query items];
            songsArray = [query items];
            break;
        case ALBUMS:
            query = [MPMediaQuery albumsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query collections];
            break;
        case GENRES:
            query = [MPMediaQuery genresQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            collectionsArray = [query collections];
            break;
        case LIBRARY:
            [self _configureMusicFolder];
            break;
            
        default:
            break;
    }
}

- (void)_configureSongsLoader:(int) index
{
    songsArray = nil;
    
    switch (collectionSelectedIndex) {
        case PLAYLISTS:
        {
            MPMediaPlaylist* playlist = [collectionsArray objectAtIndex:index];
            
            NSMutableArray* _array = [[NSMutableArray alloc] init];
            NSArray* array = [playlist items];
            
            for (MPMediaItemCollection* item in array)
            {
                MPMediaItem *representativeItem = [item representativeItem];
                
                if(representativeItem.mediaType == MPMediaTypeMusic)
                {
                    [_array addObject:item];
                }
            }
            
            songsArray = [NSArray arrayWithArray:_array];
        }
            break;
        case ARTISTS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            songsArray = [item items];
        }
            break;
        case SONGS:
        {
            MPMediaQuery* query = [MPMediaQuery songsQuery];
            [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
            songsArray = [query items];
        }
            break;
        case ALBUMS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            songsArray = [item items];
        }
            break;
        case GENRES:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            songsArray = [item items];
        }
            break;
            
        default:
            break;
    }
}

-(void) _configureMusicFolder
{
    [musicArray removeAllObjects];
    musicArray = nil;
    
    musicArray = [[NSMutableArray alloc] init];
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    
    collectionsArray = [localFileManager contentsOfDirectoryAtPath:folderPath error:nil];

    localFileManager = nil;
}

-(void) _configureMusicLoader
{
    [musicArray removeAllObjects];
    musicArray = nil;
    
    musicArray = [[NSMutableArray alloc] init];
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    folderPath = [folderPath stringByAppendingPathComponent:folderName];
    
    NSArray *files = [localFileManager contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString *filePath in files)
    {
        NSURL *mediaUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:filePath]];
        [musicArray addObject:mediaUrl];
    }

    localFileManager = nil;
}

-(void) _processMusicLoader
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    NSString *newPath = [folderPath stringByAppendingPathComponent:@"Library"];
    [localFileManager createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSArray *fileNames = [localFileManager contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString *fileName in fileNames)
    {
        NSString *oldPath = [folderPath stringByAppendingPathComponent:fileName];
        BOOL isDirectory;
        [localFileManager fileExistsAtPath:oldPath isDirectory:&isDirectory];
        if (isDirectory == NO) {
            NSString *newPath = [[folderPath stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:fileName];
            [localFileManager copyItemAtPath:oldPath toPath:newPath error:nil];
            [localFileManager removeItemAtPath:oldPath error:nil];
        }
    }

    localFileManager = nil;
}

-(NSArray *) _loadMusicFolder:(NSString *)folderName
{
    [musicArray removeAllObjects];
    musicArray = nil;
    
    musicArray = [[NSMutableArray alloc] init];
    
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    folderPath = [folderPath stringByAppendingPathComponent:folderName];
    
    NSArray *files = [localFileManager contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString *filePath in files)
    {
        NSURL *mediaUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:filePath]];
        [musicArray addObject:mediaUrl];
    }

    localFileManager = nil;
    return musicArray;
}

- (NSString *) getCollectionName:(NSInteger) index
{
    NSString* collectionName = nil;
    
    switch (collectionSelectedIndex)
    {
        case PLAYLISTS:
            collectionName = [[collectionsArray objectAtIndex:index] valueForProperty:MPMediaPlaylistPropertyName];
            break;
        case ARTISTS:
        {
            MPMediaItemCollection *item = [collectionsArray objectAtIndex:index];
            MPMediaItem *representativeItem = [item representativeItem];
            collectionName = [representativeItem valueForProperty:MPMediaItemPropertyArtist];
        }
            break;
        case ALBUMS:
        {
            MPMediaItemCollection *item = [collectionsArray objectAtIndex:index];
            MPMediaItem *representativeItem = [item representativeItem];
            collectionName = [representativeItem valueForProperty:MPMediaItemPropertyAlbumArtist];
        }
            break;
        case GENRES:
        {
            MPMediaItemCollection *item = [collectionsArray objectAtIndex:index];
            MPMediaItem *representativeItem = [item representativeItem];
            collectionName = [representativeItem valueForProperty:MPMediaItemPropertyGenre];
        }
            break;
        case LIBRARY:
        {
            collectionName = collectionsArray[index];
        }
            break;
        default:
            break;
    }
    
    return collectionName;
}

- (NSInteger) getCollectionCount:(NSInteger) index
{
    NSInteger count = 0;
    
    switch (collectionSelectedIndex)
    {
        case PLAYLISTS:
        {
            MPMediaPlaylist* playlist = [collectionsArray objectAtIndex:index];
            
            NSArray* array = [playlist items];
            
            for (MPMediaItemCollection* item in array)
            {
                MPMediaItem *representativeItem = [item representativeItem];

                if(representativeItem.mediaType == MPMediaTypeMusic)
                {
                    count++;
                }
            }
        }
            break;
        case ARTISTS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            count = item.count;
        }
            break;
        case ALBUMS:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            count = item.count;
        }
            break;
        case GENRES:
        {
            MPMediaItemCollection* item = [collectionsArray objectAtIndex:index];
            count = item.count;
        }
            break;
        case LIBRARY:
        {
            folderName = collectionsArray[index];
            count = [self _loadMusicFolder:folderName].count;
        }
            break;
        default:
            break;
    }
    
    return count;
}

- (NSString*) getSongName:(NSInteger)index
{
    NSString* songName = nil;
    MPMediaItemCollection* item = [songsArray objectAtIndex:index];
    MPMediaItem *representativeItem = [item representativeItem];
    songName = [representativeItem valueForProperty:MPMediaItemPropertyTitle];

    return songName;
}

- (NSString*) getSongDuration:(NSInteger)index
{
    MPMediaItemCollection* item = [songsArray objectAtIndex:index];
    MPMediaItem *representativeItem = [item representativeItem];
    NSNumber* duration=[representativeItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    CGFloat dur = [duration floatValue];
    int min = (int)(dur / 60.0f);
    int sec = (int)(dur - min*60);
    
    NSString* durationStr = [NSString stringWithFormat:@"%d:%02d", min, sec];

    return durationStr;
}


#pragma mark -
#pragma mark - UITabBarDelegate methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.title = item.title;
    collectionSelectedIndex = item.tag;
    
    isEdit = NO;
    isPlaying = NO;
    nPlayingIndex = -1;
    
    if (self.songPlayer)
        [self.songPlayer pause];

    [_editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    _editButton.tag = 1;
    
    [_musicTableView setEditing:NO animated:YES];

    [self _configureAlbumsLoader:collectionSelectedIndex];

    if (collectionSelectedIndex == SONGS)
    {
        [self _configureRightButton];
        
        [self.musicTableView reloadData];
        
        _musicTableView.frame = CGRectMake(0, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
        _musicTableView.hidden = NO;
        _collectionTableView.hidden = YES;
        
        self.navigationItem.leftBarButtonItem.tag = 1;
        [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"Cancel", nil)];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = nil;
        
        _collectionTableView.tag = 0;
        
        [self.collectionTableView reloadData];
        _collectionTableView.hidden = NO;
        
        _collectionTableView.userInteractionEnabled = YES;
        
        CGFloat max = self.view.frame.size.width >= self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height;
        _musicTableView.frame = CGRectMake(max, _musicTableView.frame.origin.y, _musicTableView.frame.size.width, _musicTableView.frame.size.height);
        _musicTableView.hidden = YES;
        
        self.navigationItem.leftBarButtonItem.tag = 1;
        [self.navigationItem.leftBarButtonItem setTitle:NSLocalizedString(@"Cancel", nil)];
    }
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if (tableView.tag == 0)
    {
        rows = collectionsArray.count ? : 1;
    }
    else
    {
        if (collectionSelectedIndex == LIBRARY)
            rows = musicArray.count ? : 1;
        else
            rows = songsArray.count ? : 1;
    }
    
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        height = 44.0f;
    else
        height = 54.0f;
    
    return height;
}


static NSString *const toAssetSegue = @"ToAssets";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0) //album table
    {
        BOOL showAlbumCell = collectionsArray.count > 0;
        
        if (showAlbumCell > 0)
        {
            static NSString *CellIdentifier = @"Cell";
            
            MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;

                [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
            }

            [cell.textLabel setText:[self getCollectionName:indexPath.row]];
            
            int count = (int)[self getCollectionCount:indexPath.row];
            
            if (count == 0)
            {
                [cell.detailTextLabel setText:NSLocalizedString(@"no songs", nil)];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                NSString* strCount = [[NSString stringWithFormat:@"%d ", count] stringByAppendingString:NSLocalizedString(@"songs", nil)];
                [cell.detailTextLabel setText:strCount];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            return cell;
        }
        else
        {
            static NSString *CellNoneIdentifier = @"Cell_None";
            
            MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNoneIdentifier];
            
            if (cell == nil)
            {
                cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellNoneIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
            }

            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSString* strMessage = [[NSString stringWithFormat:@"%@ ", _albumsTabbar.selectedItem.title] stringByAppendingString:NSLocalizedString(@"have not a content.", nil)];
            [cell.textLabel setText:strMessage];

            return cell;
        }
    }
    else if (tableView.tag == 1) //music table
    {
        if (collectionSelectedIndex == LIBRARY)
        {
            if (musicArray.count > 0)
            {
                static NSString *CellIdentifier = @"Cell";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.delegate = self;
                    
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    [cell.nameTextField setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                }
                
                cell.nIndex = indexPath.row;

                NSURL* musicUrl = [musicArray objectAtIndex:indexPath.row];
                NSString* musicName = [musicUrl lastPathComponent];
                
                NSRange range = [musicName rangeOfString:@".m4a"];
                if (range.length != 0)
                    musicName = [musicName substringToIndex:range.location];
                
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:musicUrl options:nil];
                CGFloat duration = asset.duration.value / asset.duration.timescale;
                
                int min = (int)(duration / 60.0f);
                int sec = (int)(duration - min*60);
                NSString* durationStr = [NSString stringWithFormat:@"%d:%02d", min, sec];
                [cell.detailTextLabel setText:durationStr];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    cell.titleLabel.frame = CGRectMake(16.0, 0, _musicTableView.frame.size.width - 120.0, cell.frame.size.height);
                    cell.nameTextField.frame = CGRectMake(16.0f, 0.0f, tableView.frame.size.width - 120.0f, cell.frame.size.height);
                    [cell.playButton setFrame:CGRectMake(_musicTableView.frame.size.width - 96.0f, 5.0f, 34.0f, 34.0f)];
                } else {
                    cell.titleLabel.frame = CGRectMake(16.0, 0, _musicTableView.frame.size.width - 152.0, cell.frame.size.height);
                    cell.nameTextField.frame = CGRectMake(16.0f, 0.0f, tableView.frame.size.width - 148.0f, cell.frame.size.height);
                    [cell.playButton setFrame:CGRectMake(_musicTableView.frame.size.width - 120.0f, 5.0f, 44.0f, 44.0f)];
                }
                
                cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);

                if (isEdit)
                {
                    [cell.nameTextField setText:musicName];
                    cell.nameTextField.userInteractionEnabled = YES;
                    [cell.titleLabel setText:@""];
                }
                else
                {
                    [cell.titleLabel setText:musicName];
                    [cell.nameTextField setText:@""];
                    cell.nameTextField.userInteractionEnabled = NO;
                }
                
                cell.originalName = musicName;
                cell.folderName = folderName;
                
                if ((indexPath.row == nPlayingIndex) && isPlaying)
                    [cell setPlaybuttonStatus:YES];
                else
                    [cell setPlaybuttonStatus:NO];
                
                return cell;
            }
            else
            {
                static NSString *CellNoneIdentifier = @"Cell_None";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNoneIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellNoneIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    
                    [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                }

                NSString* strMessage = [[NSString stringWithFormat:@"%@ ", _albumsTabbar.selectedItem.title] stringByAppendingString:NSLocalizedString(@"have not a content.", nil)];
                [cell.textLabel setText:strMessage];
                
                [cell.nameTextField setText:@""];
                cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);

                cell.originalName = @"";
                cell.folderName = @"";
                
                return cell;
            }
        }
        else
        {
            if (songsArray.count > 0)
            {
                static NSString *CellIdentifier = @"Cell";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                }

                cell.nIndex = indexPath.row;

                [cell.titleLabel setText:[self getSongName:indexPath.row]];
                [cell.detailTextLabel setText:[self getSongDuration:indexPath.row]];
                
                //[cell.nameTextField setText:[self getSongName:indexPath.row]];

                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    cell.titleLabel.frame = CGRectMake(16.0, 0, _musicTableView.frame.size.width - 120.0, cell.frame.size.height);
                    cell.nameTextField.frame = CGRectMake(16.0f, 0.0f, tableView.frame.size.width - 120.0f, cell.frame.size.height);
                    [cell.playButton setFrame:CGRectMake(_musicTableView.frame.size.width - 96.0f, 5.0f, 34.0f, 34.0f)];
                } else {
                    cell.titleLabel.frame = CGRectMake(16.0, 0, _musicTableView.frame.size.width - 152.0, cell.frame.size.height);
                    cell.nameTextField.frame = CGRectMake(16.0f, 0.0f, tableView.frame.size.width - 148.0f, cell.frame.size.height);
                    [cell.playButton setFrame:CGRectMake(_musicTableView.frame.size.width - 120.0f, 5.0f, 44.0f, 44.0f)];
                }

                if ((indexPath.row == nPlayingIndex) && isPlaying)
                    [cell setPlaybuttonStatus:YES];
                else
                    [cell setPlaybuttonStatus:NO];

                return cell;
            }
            else
            {
                static NSString *CellNoneIdentifier = @"Cell_None";
                
                MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNoneIdentifier];
                
                if (cell == nil)
                {
                    cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellNoneIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    
                    [cell.textLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                    [cell.detailTextLabel setFont:[UIFont fontWithName:MYRIADPRO size:[UIFont systemFontSize]]];
                }

                NSString* strMessage = [[NSString stringWithFormat:@"%@ ", _albumsTabbar.selectedItem.title] stringByAppendingString:NSLocalizedString(@"have not a content.", nil)];
                [cell.textLabel setText:strMessage];

                [cell.nameTextField setText:@""];
                cell.nameTextField.frame = CGRectMake(50.0f, 0.0f, cell.frame.size.width - 50.0f - cell.detailTextLabel.frame.size.width, cell.frame.size.height);
                
                return cell;
            }
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (collectionsArray.count > 0 && tableView.tag == 0)
    {
        if ([self getCollectionCount:indexPath.row] > 0)
        {
            [self.navigationItem.leftBarButtonItem setTitle:[NSString stringWithFormat:@"< %@", self.title]];
            self.title = [self getCollectionName:indexPath.row];
            self.navigationItem.leftBarButtonItem.tag = 2;
            
            [self _configureSongsLoader:(int)indexPath.row];
            
            if (collectionSelectedIndex == LIBRARY) {
                [self _configureEditButton];
            } else {
                [self _configureRightButton];
            }
            
            [self.musicTableView reloadData];
            
            _musicTableView.hidden = NO;
            _collectionTableView.userInteractionEnabled = NO;
            
            [UIView animateWithDuration:0.2f animations:^{
                self.musicTableView.frame = CGRectMake(0, self.musicTableView.frame.origin.y, self.musicTableView.frame.size.width, self.musicTableView.frame.size.height);
            }];
        }
    }
    else if ((songsArray.count > 0 && tableView.tag == 1) || (musicArray.count > 0 && tableView.tag == 1))
    {
        if (self.songPlayer)
        {
            [self.songPlayer pause];
            self.songPlayer = nil;
        }
        
        if (collectionSelectedIndex == LIBRARY)
        {
            self.assetUrl = [musicArray objectAtIndex:indexPath.row];
            
            if (([self.customMusicController.customMusicDelegate respondsToSelector:@selector(musicPickerControllerDidSelected:asset:)]) && (self.assetUrl != nil))
            {
                [self.customMusicController.customMusicDelegate musicPickerControllerDidSelected:self.customMusicController asset:self.assetUrl];
            }
            else if (self.assetUrl == nil)
            {
                [self showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"You can`t use this music. Please use this music after download music from the iTunes Store.", nil) okHandler:nil];
            }
        }
        else
        {
            MPMediaItemCollection* item = [songsArray objectAtIndex:indexPath.row];
            MPMediaItem *representativeItem = [item representativeItem];
            self.assetUrl = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
            
            if (([self.customMusicController.customMusicDelegate respondsToSelector:@selector(musicPickerControllerDidSelected:asset:)]) && (self.assetUrl != nil))
            {
                [self.customMusicController.customMusicDelegate musicPickerControllerDidSelected:self.customMusicController asset:self.assetUrl];
            }
            else if (self.assetUrl == nil)
            {
                [self showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"You can`t use this music. Please use this music after download music from the iTunes Store.", nil) okHandler:nil];
            }
        }
    }
}


- (void)tableView:(UITableView *)tableview commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionSelectedIndex == LIBRARY && tableview.tag == 1 && editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSURL* musicUrl = [musicArray objectAtIndex:indexPath.row];
        [[NSFileManager defaultManager] removeItemAtPath:musicUrl.path error:NULL];
        
        [musicArray removeObjectAtIndex:indexPath.row];

        [_musicTableView reloadData];
        
        if (musicArray.count == 0)
        {
            isEdit = NO;
            
            [_editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
            _editButton.tag = 1;
            
            [_musicTableView setEditing:NO animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionSelectedIndex == LIBRARY && tableView.tag == 1 && musicArray.count > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    return YES;
}


- (void)changedMusicName
{
    [self _configureMusicLoader];
}

- (void)selectedPlayIndex:(NSInteger) nIndex isPlayingStatus:(BOOL) playing
{
    isPlaying = playing;
    
    if (isPlaying)
    {
        if (nPlayingIndex == nIndex)
        {
            if (self.songPlayer)
                [self.songPlayer play];
            else
            {
                if (collectionSelectedIndex == LIBRARY)
                {
                    if (musicArray.count > nPlayingIndex)
                    {
                        self.assetUrl = [musicArray objectAtIndex:nPlayingIndex];
                        
                        if (!self.songPlayer)
                            self.songPlayer = [AVPlayer playerWithURL:self.assetUrl];
                        else
                            [self.songPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.assetUrl]];
                        
                        [self.songPlayer play];
                    }
                }
                else
                {
                    if (songsArray.count > nPlayingIndex)
                    {
                        MPMediaItemCollection* item = [songsArray objectAtIndex:nPlayingIndex];
                        MPMediaItem *representativeItem = [item representativeItem];
                        self.assetUrl = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
                        
                        if (!self.songPlayer)
                            self.songPlayer = [AVPlayer playerWithURL:self.assetUrl];
                        else
                            [self.songPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.assetUrl]];
                        
                        [self.songPlayer play];
                    }
                }
            }
        }
        else
        {
            nPlayingIndex = nIndex;

            if (collectionSelectedIndex == LIBRARY)
            {
                if (musicArray.count > nPlayingIndex)
                {
                    self.assetUrl = [musicArray objectAtIndex:nPlayingIndex];
                    
                    if (!self.songPlayer)
                        self.songPlayer = [AVPlayer playerWithURL:self.assetUrl];
                    else
                        [self.songPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.assetUrl]];
                    
                    [self.songPlayer play];
                }
            }
            else
            {
                if (songsArray.count > nPlayingIndex)
                {
                    MPMediaItemCollection* item = [songsArray objectAtIndex:nPlayingIndex];
                    MPMediaItem *representativeItem = [item representativeItem];
                    self.assetUrl = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
                    
                    if (!self.songPlayer)
                        self.songPlayer = [AVPlayer playerWithURL:self.assetUrl];
                    else
                        [self.songPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.assetUrl]];
                    
                    [self.songPlayer play];
                }
            }
        }
    }
    else
    {
        nPlayingIndex = nIndex;

        if (self.songPlayer)
            [self.songPlayer pause];
    }
    
    [self.musicTableView reloadData];
}

@end

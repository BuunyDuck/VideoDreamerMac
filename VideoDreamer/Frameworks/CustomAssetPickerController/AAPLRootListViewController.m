//
//  AAPLRootListViewController.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "AAPLRootListViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "CustomAssetPickerController.h"
#import "AAPLAssetGridViewController.h"

#import "Definition.h"


@import Photos;


@interface AAPLRootListViewController ()<PHPhotoLibraryChangeObserver>

@property (strong) NSMutableArray* collectionsArray;

@end


@implementation AAPLRootListViewController

@synthesize customAssetPickerController = _customAssetPickerController;

static NSString * const CollectionSegue = @"showCollection";


- (void)awakeFromNib
{
    [self addActivityIndicatorToNavigationBar];
    
    NSDictionary* normalButtonItemAttributes =  @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                  NSForegroundColorAttributeName:[UIColor blackColor]};
    NSDictionary* highlightButtonItemAttributes =  @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                     NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    
    [self.cancelButtonItem setTitleTextAttributes:normalButtonItemAttributes forState:UIControlStateNormal];
    [self.cancelButtonItem setTitleTextAttributes:highlightButtonItemAttributes forState:UIControlStateHighlighted];
    [super awakeFromNib];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.tableView.backgroundView = imageView;
    self.tableView.sectionHeaderHeight = 0.0;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0.0;
    } else {
        // Fallback on earlier versions
    }
 
    self.customAssetPickerController = (CustomAssetPickerController*)self.navigationController;
    
    filterType = self.customAssetPickerController.filterType;
    
    if (!self.collectionsArray)
    {
        self.collectionsArray = [[NSMutableArray alloc] init];
    }
    //if (filterType == PHAssetMediaTypeVideo)
    [self checkPhotoLibraryAuthorization:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self loadPhotoLibrary];
            } else {
                [self showPhotoAuthorizationErrorAlert];
            }
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self removeActivityIndicatorFromNavigationBar];
}

- (void)loadPhotoLibrary {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    //smart albums
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //top level albums
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    [self addCollections:smartAlbums];
    [self addCollections:topLevelUserCollections];
    
    [self.tableView reloadData];
}

- (void)checkPhotoLibraryAuthorization:(void(^)(BOOL granted))completion
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        completion(YES);
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                completion(YES);
            } else {
                completion(NO);
            }
        }];
    } else {
        completion(NO);
    }
}

- (void)showPhotoAuthorizationErrorAlert
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied)
    {
        [self showAlertViewController:NSLocalizedString(@"Video Dreamer is unable to access Camera Roll", nil) message:NSLocalizedString(@"To enable access to the Camera Roll, follow these steps:\r\n Go to: Settings -> Privacy -> Photos and turn ON access for Video Dreamer.", nil) okHandler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.collectionsArray removeAllObjects];
        self.collectionsArray = [[NSMutableArray alloc] init];
        
        //smart albums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        //top level albums
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        [self addCollections:smartAlbums];
        [self addCollections:topLevelUserCollections];
        
        [self.tableView reloadData];
    });
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:CollectionSegue])
    {
        AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        if (indexPath.row == self.collectionsArray.count)
        {
            if (filterType == PHAssetMediaTypeImage)    //Add Shapes at last of Photos Albums
            {
                assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:filterType options:options];
                assetGridViewController.title = NSLocalizedString(@"Shapes", nil);
                assetGridViewController.filterType = filterType;
                assetGridViewController.customAssetPickerController = self.customAssetPickerController;
            }
            else if (filterType == PHAssetMediaTypeVideo)    //Add iTunes Synced Movies at last of Videos Albums
            {
                assetGridViewController.assetsFetchResults = nil;
                assetGridViewController.title = NSLocalizedString(@"Movies", nil);
                assetGridViewController.filterType = filterType;
                assetGridViewController.customAssetPickerController = self.customAssetPickerController;
            }
        }
        else
        {
            PHCollection *collection = [self.collectionsArray objectAtIndex:indexPath.row];
            
            if ([collection isKindOfClass:[PHAssetCollection class]])
            {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                
                assetGridViewController.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                assetGridViewController.assetCollection = assetCollection;
                assetGridViewController.title = assetCollection.localizedTitle;
                assetGridViewController.filterType = filterType;
                assetGridViewController.customAssetPickerController = self.customAssetPickerController;
            }
        }
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = self.collectionsArray.count + 1;   // add Shapes or Movies
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *localizedTitle = nil;
    NSInteger count = 0;
    
    if (indexPath.row == self.collectionsArray.count)
    {
        if (filterType == PHAssetMediaTypeImage)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            localizedTitle = NSLocalizedString(@"Shapes", nil);
            
            count = SHAPES_MAX_COUNT;
        }
        else if(filterType == PHAssetMediaTypeVideo)
        {
            NSNumber *mediaTypeNumber = [NSNumber numberWithInteger:MPMediaTypeAnyVideo];
            MPMediaPropertyPredicate *mediaTypePredicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber
                                                                                            forProperty:MPMediaItemPropertyMediaType];
            NSSet *predicateSet = [NSSet setWithObjects:mediaTypePredicate, nil];
            MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
            NSArray* moviesArray = [query collections];
            
            for (int i = 0; i < moviesArray.count; i++)
            {
                MPMediaItemCollection* item = [moviesArray objectAtIndex:i];
                MPMediaItem *representativeItem = [item representativeItem];
                NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
                
                if (url)
                {
                    count++;
                }
            }

            cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
            localizedTitle = NSLocalizedString(@"Movies", nil);
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
        
        PHCollection *collection = [self.collectionsArray objectAtIndex:indexPath.row];
        localizedTitle = collection.localizedTitle;
        
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            count = [assetsFetchResult countOfAssetsWithMediaType:filterType];
        }
    }
    
    cell.textLabel.text = localizedTitle;
    cell.textLabel.font = [UIFont fontWithName:MYRIADPRO size:16.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)count];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont fontWithName:MYRIADPRO size:16.0];
    
    cell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];

    return cell;
}


#pragma mark - Actions

- (IBAction)handleCancelButtonItem:(id)sender
{
    if ([self.customAssetPickerController.customAssetDelegate respondsToSelector:@selector(customAssetsPickerControllerDidCancel:)])
    {
        [self.customAssetPickerController.customAssetDelegate customAssetsPickerControllerDidCancel:self.customAssetPickerController];
    }
}


#pragma mark - Add PHFetchResult

-(void) addCollections:(PHFetchResult*) result
{
    for (int i = 0; i < result.count; i++)
    {
        PHCollection *collection = result[i];
        
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            
            if ([assetsFetchResult countOfAssetsWithMediaType:filterType] > 0)
            {
                [self.collectionsArray addObject:collection];
            }
        }
    }
}

- (void)addActivityIndicatorToNavigationBar
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _indicatorView.color = [UIColor grayColor];
        [_indicatorView setHidesWhenStopped:YES];
    }
    
    UIBarButtonItem *itemIndicator = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
    [self.navigationItem setRightBarButtonItem:itemIndicator];
    [_indicatorView startAnimating];
}

- (void)removeActivityIndicatorFromNavigationBar
{
    [_indicatorView stopAnimating];
}



@end

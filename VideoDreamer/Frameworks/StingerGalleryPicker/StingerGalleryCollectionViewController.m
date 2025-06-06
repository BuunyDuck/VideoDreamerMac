//
//  StingerGalleryCollectionViewController.m
//  VideoFrame
//
//  Created by APPLE on 10/11/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "StingerGalleryCollectionViewController.h"
#import "Definition.h"

@interface StingerGalleryCollectionViewController ()
{
    IBOutlet UIBarButtonItem *cancelButton;
}

@end

@implementation StingerGalleryCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;

-(void) awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    
    NSDictionary *normalButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                 NSForegroundColorAttributeName:[UIColor blackColor]};
    NSDictionary *highlightButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                    NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    [cancelButton setTitleTextAttributes:normalButtonItemAttributes forState:UIControlStateNormal];
    [cancelButton setTitleTextAttributes:highlightButtonItemAttributes forState:UIControlStateHighlighted];
    
    stingerNameArray = [[NSArray alloc] initWithObjects:@"StingerA", @"StingerB", @"StingerC", @"StingerD", nil];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"specialistEditBg"]];
    self.collectionView.backgroundView = imageView;

    self.stingerGalleryPickerController = (StingerGalleryPickerController*)self.navigationController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize cellSize = CGSizeZero;
    CGRect bounds = [UIScreen mainScreen].bounds;
#if TARGET_OS_MACCATALYST
    bounds = SCREEN_FRAME_LANDSCAPE;
#endif
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        myCell_Size = MIN(bounds.size.width, bounds.size.height) / 3.0f - 7.0f;
    else
        myCell_Size = MAX(bounds.size.width, bounds.size.height) / 7.0f - 5.0f;
    
    cellSize = CGSizeMake(myCell_Size, myCell_Size);
    
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = cellSize;
    
    AssetGridThumbnailSize = CGSizeMake(cellSize.width*2.0f, cellSize.height*2.0f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(AssetGridThumbnailSize.width/2.0f, AssetGridThumbnailSize.height/2.0f);
}

#pragma mark <UICollectionViewDataSource>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return stingerNameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StingerGalleryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NSString* nameStr = [stingerNameArray objectAtIndex:indexPath.row];
    cell.videoNameLabel.text = nameStr;
    
    NSString* thumbnailName = [nameStr stringByAppendingString:@"_Thumbnail"];
    cell.thumbnailImageView.image = [UIImage imageNamed:thumbnailName];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:nameStr ofType:@"mp4" inDirectory:nil];
    NSURL* videoURL = [NSURL fileURLWithPath:path];
    AVURLAsset* asset = [AVURLAsset assetWithURL:videoURL];
    
    CGSize videoSize = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    cell.pixelLabel.text = [NSString stringWithFormat:@"%d x %d", (int)videoSize.width, (int)videoSize.height];

    CMTime duration = asset.duration;
    CGFloat seconds = CMTimeGetSeconds(duration);
    NSString* durationStr = [self timeToString:seconds];
    cell.durationLabel.text = durationStr;
    
    NSNumber *size;
    [videoURL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
    
    //Binary Size
    CGFloat byte = (CGFloat)[size floatValue];
    NSString* videoSizeString = nil;
    
    if (byte >= (1024.0f*1024.0f))
    {
        byte = byte / (1024.0f*1024.0f);
        videoSizeString = [NSString stringWithFormat:@"%.1fMB", byte];
    }
    else if (byte >= 1024.0f)
    {
        byte = byte / 1024.0f;
        videoSizeString = [NSString stringWithFormat:@"%.1fKB", byte];
    }
    else
    {
        videoSizeString = [NSString stringWithFormat:@"%.1fB", byte];
    }

    cell.sizeLabel.text = videoSizeString;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* nameStr = [stingerNameArray objectAtIndex:indexPath.row];

    if ([self.stingerGalleryPickerController.stingerGalleryPickerControllerDelegate respondsToSelector:@selector(stingerGalleryPickerController:didFinishPickingStingerName:)])
    {
        [self.stingerGalleryPickerController.stingerGalleryPickerControllerDelegate stingerGalleryPickerController:self.stingerGalleryPickerController didFinishPickingStingerName:nameStr];
    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (NSString *)timeToString:(CGFloat)time
{
    // time - seconds
    int min = floor(time / 60);
    int sec = floor(time - min * 60);
    
    NSString *minStr = [NSString stringWithFormat:@"%d", min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%d" : @"0%d", sec];
    
    return [NSString stringWithFormat:@"%@:%@", minStr, secStr];
}

- (IBAction)handleCancelButtonItem:(id)sender
{
    if ([self.stingerGalleryPickerController.stingerGalleryPickerControllerDelegate respondsToSelector:@selector(stingerGalleryPickerControllerDidCancel:)])
    {
        [self.stingerGalleryPickerController.stingerGalleryPickerControllerDelegate stingerGalleryPickerControllerDidCancel:self.stingerGalleryPickerController];
    }
}
@end

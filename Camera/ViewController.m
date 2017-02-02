//
//  ViewController.m
//  Camera
//
//  Created by wanghuiyong on 02/02/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;			// 使用从图像选取器返回的图像以更新图像视图
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;	// 用于按钮的显示和隐藏

@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;	// 抓取 view 属性插入视图层次中
@property (strong, nonatomic) UIImage *image;				// 最后选择的照片
@property (strong, nonatomic) NSURL *movieURL;				// 最后选择的视频
@property (copy, nonatomic) NSString *lastChosenMediaType;	// 最后选择的类型, 进入选取器时赋值, 返回时根据选择类型进行显示

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];		// 加载 storyboard 中的视图对象?
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.takePictureButton.hidden = YES;
    }
}

// 启动时以及从图像选取器返回控制器界面时调用
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateDisplay];
}

- (void)updateDisplay {
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        // 在选取器中选择了图像则返回到控制器后显示图像, 隐藏视频
        self.imageView.image = self.image;
        self.imageView.hidden = NO;
        self.moviePlayerController.view.hidden = YES;
    } else if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        // 选择视频则相反
        if (self.moviePlayerController == nil) {
            // 首次选取影片, 影片播放器要刚好覆盖图像视图
            self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:self.movieURL];
            UIView *movieView = self.moviePlayerController.view;
            movieView.frame = self.imageView.frame;
            movieView.clipsToBounds = YES;
            [self.view addSubview:movieView];
            [self setMoviePlayerLayoutConstraints];
        } else {
            self.moviePlayerController.contentURL = self.movieURL;
        }
        self.imageView.hidden = YES;
        self.moviePlayerController.view.hidden = NO;
        [self.moviePlayerController play];
    }
}

- (void)setMoviePlayerLayoutConstraints {
    UIView *moviePlayerView = self.moviePlayerController.view;
    UIView *takePictureButton = self.takePictureButton;
    moviePlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(moviePlayerView, takePictureButton);
    // 添加约束
    [self.view addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moviePlayerView]|" options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[moviePlayerView]-0-[takePictureButton]|" options:0 metrics:nil views:views]];
}

- (IBAction)shootPictureOrVideo:(UIButton *)sender {
    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)selectExistingPictureOrVideo:(UIButton *)sender {
    [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    // 源类型可用且媒体文件数量大于零
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        // 配置并进入图像选取器
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing  =YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        NSString *title = @"Error accessing media";
        NSString *msg = @"Unsuppoeted media source";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Image Picker Controller Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    self.lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        // 选择图像
        self.image = info[UIImagePickerControllerEditedImage];	// 返回编辑后的图像
    } else if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        // 选择视频
        self.movieURL = info[UIImagePickerControllerMediaURL];
    }
    // 选择完成返回
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // 取消选择返回
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end

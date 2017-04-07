//
//  GlobalImageViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 03/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GlobalImageViewController.h"

@interface GlobalImageViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *globalImageView;
@end

@implementation GlobalImageViewController
@synthesize globalImage;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
    
    self.scrollView.contentSize = self.view.bounds.size;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 3.0f;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"viewForZoomingInScrollView");
    return self.globalImageView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
//    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPinch:)];
//    [self.globalImageView addGestureRecognizer:twoFingerPinch];
//    self.globalImageView.userInteractionEnabled=YES;
    self.globalImageView.image=globalImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

- (void)twoFingerPinch:(UIPinchGestureRecognizer *)recognizer
{
//    _scale = recognizer.scale;
    CGAffineTransform tr = CGAffineTransformScale(self.globalImageView.transform, recognizer.scale, recognizer.scale);
    self.globalImageView.transform = tr;
//    if([recognizer state] == UIGestureRecognizerStateBegan) {
//        previousScale = 1.0;
//        lastPoint = [recognizer locationInView:[recognizer view]];
//    }
//    
//    if (
//        [recognizer state] == UIGestureRecognizerStateChanged) {
//        
//        CGFloat currentScale = [[[recognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
//        
//        // Constants to adjust the max/min values of zoom
//        const CGFloat kMaxScale = 4.0;
//        const CGFloat kMinScale = 1.0;
//        
//        CGFloat newScale = 1 -  (previousScale - [recognizer scale]); // new scale is in the range (0-1)
//        newScale = MIN(newScale, kMaxScale / currentScale);
//        newScale = MAX(newScale, kMinScale / currentScale);
//        scale = newScale;
//        
//        CGAffineTransform transform = CGAffineTransformScale([[recognizer view] transform], newScale, newScale);
//        
//        [recognizer view].transform = transform;
//        
//        CGPoint point = [recognizer locationInView:[recognizer view]];
//        CGAffineTransform transformTranslate = CGAffineTransformTranslate([[recognizer view] transform], point.x-lastPoint.x, point.y-lastPoint.y);
//        
//        [recognizer view].transform = transformTranslate;
//    }
}

#pragma mark - IBAction
- (IBAction)cancelAction:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

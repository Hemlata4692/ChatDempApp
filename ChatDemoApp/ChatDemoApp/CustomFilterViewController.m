//
//  CustomFilterViewController.m
//  Dwell
//
//  Created by Ranosys on 16/09/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "CustomFilterViewController.h"
static int const widthValue=250;
static int heightValue=200;

@interface CustomFilterViewController ()

@property (strong, nonatomic) IBOutlet UIView *tapGestureView;
@property (strong, nonatomic) IBOutlet UITableView *filterTableView;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImage;
@end

@implementation CustomFilterViewController
@synthesize filterContainverView;
@synthesize filterDict;
@synthesize isAllSelected;

@synthesize filterArray;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
    heightValue=(80*(int)filterArray.count)+15;
    if (heightValue>[[UIScreen mainScreen] bounds].size.height-64) {
        heightValue=[[UIScreen mainScreen] bounds].size.height-64;
    }
    [self removeAutolayout];
    [self layoutViewObjects];
    [self.filterTableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self showViewAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return filterArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    NSString *simpleTableIdentifier=@"filterCell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    UILabel *statusLabel=(UILabel *)[cell viewWithTag:2];
    UIImageView *checkedImage=(UIImageView *)[cell viewWithTag:1];
    
    statusLabel.text=[filterArray objectAtIndex:indexPath.row];
    statusLabel.textColor=[UIColor colorWithRed:98.0/255 green:98.0/255.0 blue:98.0/255.0 alpha:1.0];
    if ([[filterDict objectForKey:[filterArray objectAtIndex:indexPath.row]] intValue]==1) {
        NSLog(@"1");
        checkedImage.image=[UIImage imageNamed:@"documentsAttachment"];
    }
    else if ([[filterDict objectForKey:[filterArray objectAtIndex:indexPath.row]] intValue]==2) {
        NSLog(@"2");
        checkedImage.image=[UIImage imageNamed:@"cameraAttachment"];
    }
    else {
        NSLog(@"3");
        checkedImage.image=[UIImage imageNamed:@"galleryAttachment"];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    filterContainverView.frame=CGRectMake([[UIScreen mainScreen] bounds].size.width-30, 57, 0, 0);
    self.arrowImage.frame=CGRectMake(-10, 0, 20, 11);
    self.filterContainverView.alpha = 0.0f;
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    [_delegate customFilterDelegateAction:[[filterDict objectForKey:[filterArray objectAtIndex:indexPath.row]] intValue]];
}
#pragma mark - end

#pragma mark - Show/Hide animation
- (void)hideViewAnimation {
    
    [UIView animateWithDuration:0.2f animations:^{
        //To Frame
        filterContainverView.frame=CGRectMake([[UIScreen mainScreen] bounds].size.width-30, 57, 0, 0);
        self.arrowImage.frame=CGRectMake(-10, 0, 20, 11);
        self.filterContainverView.alpha = 0.0f;
    } completion:^(BOOL completed) {
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)showViewAnimation {
    
    [UIView animateWithDuration:0.2f animations:^{
        //To Frame
        filterContainverView.frame=CGRectMake([[UIScreen mainScreen] bounds].size.width-widthValue-10, 57, widthValue, heightValue);
        self.arrowImage.frame=CGRectMake(widthValue-30, 0, 20, 11);
        self.filterContainverView.alpha = 1.0f;
    } completion:^(BOOL completed) {
    }];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)hideFilter:(UITapGestureRecognizer *)sender {
    
    [self hideViewAnimation];
}
#pragma mark - end

#pragma mark -Custom accessors
- (void)removeAutolayout {
    
    filterContainverView.translatesAutoresizingMaskIntoConstraints=YES;
    self.filterTableView.translatesAutoresizingMaskIntoConstraints=YES;
    self.arrowImage.translatesAutoresizingMaskIntoConstraints=YES;
}

- (void)layoutViewObjects {
    
    self.tapGestureView.translatesAutoresizingMaskIntoConstraints=YES;
    self.tapGestureView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    filterContainverView.backgroundColor=[UIColor clearColor];
    filterContainverView.frame=CGRectMake([[UIScreen mainScreen] bounds].size.width-30, 57, 0, 0);
    self.arrowImage.frame=CGRectMake(-10, 0, 20, 11);
    self.filterTableView.frame=CGRectMake(0, 11, widthValue, heightValue-16);
    self.filterTableView.layer.cornerRadius=5.0f;
    self.filterTableView.layer.masksToBounds=YES;
    filterContainverView.layer.masksToBounds=YES;
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

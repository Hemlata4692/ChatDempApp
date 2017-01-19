//
//  DashboardViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DashboardViewController.h"
#import "UserDefaultManager.h"
#import "HMSegmentedControl.h"

@interface DashboardViewController () {

    HMSegmentedControl *customSegmentedControl;
}
@end

@implementation DashboardViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Dashboard";
    [self addBarButton];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self addSegmentBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom accessors
- (void)addBarButton {
    
    UIBarButtonItem *logoutBarButton;
    CGRect framing = CGRectMake(0, 0, 60, 30.0);
    UIButton *logout = [[UIButton alloc] initWithFrame:framing];
    [logout setTitle:@"Logout" forState:UIControlStateNormal];
    logoutBarButton =[[UIBarButtonItem alloc] initWithCustomView:logout];
    [logout addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:logoutBarButton, nil];
    
    UIBarButtonItem *groupBarButton;
    UIButton *group = [[UIButton alloc] initWithFrame:framing];
    [group setTitle:@"Group" forState:UIControlStateNormal];
    groupBarButton =[[UIBarButtonItem alloc] initWithCustomView:group];
    [group addTarget:self action:@selector(groupAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:groupBarButton, nil];
}
#pragma mark - end

#pragma mark - IBActions
- (void)logoutAction :(id)sender {
    
        [UserDefaultManager setValue:nil key:@"userName"];
 
    
    [self userLogout];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [myDelegate.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                               animated: NO];
}

- (void)groupAction :(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *objGroupView = [storyboard instantiateViewControllerWithIdentifier:@"GroupConversationViewController"];
    [self.navigationController pushViewController:objGroupView animated:YES];
}
#pragma mark - end

- (void)addSegmentBar {
    
    customSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                              @[@"History", @"Contacts"]];
    customSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    customSegmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    customSegmentedControl.backgroundColor=[UIColor darkGrayColor];
    customSegmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    customSegmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    customSegmentedControl.selectionIndicatorHeight = 3.0;
    customSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;//
    customSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    customSegmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Helvetica-Bold" size:16], NSFontAttributeName,
                                [UIColor grayColor].CGColor, NSForegroundColorAttributeName, nil];
    
    [customSegmentedControl setTitleTextAttributes:attributes];
    
    [customSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:customSegmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
        
    }
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

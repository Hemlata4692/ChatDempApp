//
//  GroupConversationViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupConversationViewController.h"

@interface GroupConversationViewController () {

    AppDelegateObjectFile *appDelegate;
}

@end

@implementation GroupConversationViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"GroupChat";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white"] addChat:[UIImage imageNamed:@"addIcon"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

- (IBAction)create:(UIButton *)sender {
    
    [self createChatRoom];
}

- (IBAction)list:(UIButton *)sender {
    
    [self fetchList];
}

- (IBAction)join:(UIButton *)sender {
}

- (IBAction)invite:(UIButton *)sender {
}

- (IBAction)delete:(UIButton *)sender {
}

#pragma mark - Custom accessors
- (void)addLeftBarButtonWithImage:(UIImage *)backImage addChat:(UIImage *)addChatImage {
    
    UIBarButtonItem *backBarButton;
    CGRect framing = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setBackgroundImage:backImage forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:backBarButton, nil];
    
    UIBarButtonItem *addBarButton;
    framing = CGRectMake(0, 0, addChatImage.size.width, addChatImage.size.height);
    UIButton *addChat = [[UIButton alloc] initWithFrame:framing];
    [addChat setBackgroundImage:addChatImage forState:UIControlStateNormal];
    addBarButton =[[UIBarButtonItem alloc] initWithCustomView:addChat];
    [addChat addTarget:self action:@selector(addChatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:addBarButton, nil];
}
#pragma mark - end

#pragma mark - IBActions
//Back button action
- (void)backButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addChatButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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

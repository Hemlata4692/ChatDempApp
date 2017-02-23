//
//  DocumentAttachmentViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 23/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DocumentAttachmentViewController.h"

@interface DocumentAttachmentViewController ()<UIDocumentInteractionControllerDelegate> {

    bool isWebViewOpen;
    NSMutableArray *documentArray;
}
@property (strong, nonatomic) IBOutlet UITableView *documentTableView;

@property (strong, nonatomic) IBOutlet UILabel *customNavigationTitle;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (retain,nonatomic) UIDocumentInteractionController *docController;
@end

@implementation DocumentAttachmentViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    isWebViewOpen=false;
    documentArray=[NSMutableArray new];
    [self fetchAllDocuments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View initializer
- (void)fetchAllDocuments {

    [myDelegate getAllDocumentListing:^(NSMutableArray *tempArray) {
        // do something with your BOOL
        documentArray=[tempArray mutableCopy];
        [self.documentTableView reloadData];
    }];
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return documentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    NSString *simpleTableIdentifier = @"cell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    UILabel *fileTitle=(UILabel *)[cell viewWithTag:2];
    UIImageView *fileIcon=(UIImageView *)[cell viewWithTag:1];
    UIButton *viewFile=(UIButton *)[cell viewWithTag:3];
    viewFile.tag=indexPath.row;
    [viewFile addTarget:self action:@selector(viewFileAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[documentArray objectAtIndex:indexPath.row] pathExtension] isEqualToString:@"pdf"]) {
        fileIcon.image=[UIImage imageNamed:@"pdfIcon"];
    }
    fileTitle.text=[documentArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    isWebViewOpen=true;
    [_delegate sendDocumentDelegateAction:[documentArray objectAtIndex:indexPath.row]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - end

#pragma mark - UIActions
- (IBAction)cancel:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)viewFileAction:(UIButton *)sender {
    
    NSURL *url = [NSURL fileURLWithPath:[myDelegate documentCacheDirectoryPathFileName:[documentArray objectAtIndex:[sender tag]]]];
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.docController.delegate = self;
    [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

//- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
//    
//    NSLog(@"willBeginSendingToApplication");
//}
//
//- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
//    NSLog(@"didEndSendingToApplication");
//    
//}
//
//- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
//    NSLog(@"documentInteractionControllerDidDismissOpenInMenu");
//    
//}
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

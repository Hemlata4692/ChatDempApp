//
//  ViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+Validations.h"
#import "UserDefaultManager.h"
#import "RegisterViewController.h"
#import "DashboardViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;

//Declare BSKeyboard variable
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation ViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Login";
    
    //Adding textfield to keyboard controls array
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[self.usernameField]]];
    [self.keyboardControls setDelegate:self];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls {
    
    [keyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Login validation
- (BOOL)performValidationsForLogin {
    
    if ([self.usernameField isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Please fill in the field."];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)login:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if ([self performValidationsForLogin]) {
        
        [myDelegate showIndicator];
        [self performSelector:@selector(userLogin) withObject:nil afterDelay:2];
    }
}

- (IBAction)register:(UIButton *)sender {
    
    RegisterViewController * objSignUpView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:objSignUpView animated:YES];
}
#pragma mark - end

#pragma mark - Webservice
- (void)userLogin {

    [myDelegate stopIndicator];
    [UserDefaultManager setValue:self.usernameField.text key:@"userName"];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
    [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
                                         animated: NO];
}
#pragma mark - end
@end

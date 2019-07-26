//
//  OEXMySettingsViewController.m
//  edXVideoLocker
//
//  Created by Abhradeep on 20/02/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "OEXMySettingsViewController.h"

#import "edX-Swift.h"

#import "NSString+OEXFormatting.h"
#import "OEXInterface.h"
#import "OEXStyles.h"
#import "NSObject+OEXReplaceNull.h"

typedef NS_ENUM(NSUInteger, OEXMySettingsAlertTag) {
    OEXMySettingsAlertTagNone,
    OEXMySettingsAlertTagWifiOnly
};

@interface OEXMySettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell* wifiOnlyCell;
@property (weak, nonatomic) IBOutlet UISwitch* wifiOnlySwitch;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic,strong) NSString *localVersion;
@property (nonatomic,strong) NSString *storeVersion;

@end

@implementation OEXMySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.title = [Strings settings];
    
    self.localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[OEXAnalytics sharedAnalytics] trackScreenWithName:OEXAnalyticsScreenSettings];
}

- (void)initTableView {
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    self.tableView.separatorColor = [UIColor colorWithHexString:@"#f5f5f5"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.tableFooterView = [UIView new];
    
    [self.wifiOnlySwitch setOn:[OEXInterface shouldDownloadOnlyOnWifi]];
    [self.wifiOnlySwitch setOnTintColor:[OEXStyles sharedStyles].primaryBaseColor];
    
    [self.subtitleLabel setTextAlignment:NSTextAlignmentNatural];
    [self.subtitleLabel setText:[Strings wifiOnlyDetailMessage]];
    
    OEXTextStyle *textStyle = [[OEXTextStyle alloc] initWithWeight:OEXTextWeightNormal size:OEXTextSizeLarge color:[[OEXStyles sharedStyles] neutralBlack]];
    self.titleLabel.attributedText = [textStyle attributedStringWithText:[Strings wifiOnlyTitle]];
    self.wifiOnlyCell.accessibilityLabel = [NSString stringWithFormat:@"%@ , %@", self.titleLabel.text, self.subtitleLabel.text];
}

#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 55;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return self.wifiOnlyCell;
                break;
            default: {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"updateVersionCell"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"updateVersionCell"];
                    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
                    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
                    cell.textLabel.textColor = [UIColor colorWithHexString:@"#2e313c"];
                    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#ccd1d9"];
                    cell.textLabel.text = @"版本更新";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"V%@",self.localVersion];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                return cell;
            }
                break;
        }
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logoutCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logoutCell"];
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#2e313c"];
        cell.textLabel.text = Strings.logout;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {//版本更新
            [self judgeAppStoreVersion];
        }
    }
    else {
        if (self.logoutHandle) {
            self.logoutHandle();
        }
    }
}

- (void)judgeAppStoreVersion { //通过App Store来判断
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSString *path = @"https://itunes.apple.com/lookup?bundleId=cn.elitemba.iOS&country=cn";
    
    [manager GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *appInfo = (NSDictionary *)responseObject;
        NSArray *infoArray = appInfo[@"results"];
        
        if (infoArray.count == 0) {
            return;
        }
        
        NSDictionary *versionDic = [infoArray[0] oex_replaceNullsWithEmptyStrings];
        self.storeVersion = versionDic[@"version"]; //线上版本号
        
        BOOL isDescending = [self.storeVersion compare:self.localVersion options:NSNumericSearch] == NSOrderedDescending; //是否是降序
        if (!isDescending) { //App store 版本号 = 本地的版本号
            [self lastVersion];
            return;
        }
        [self updateAppVersion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"查询iTunes应用信息错误：%@",error.description);
        [self gotoAppStore];
    }];
}

- (void)gotoAppStore {
    
    NSURL *url = [OEXConfig sharedConfig].appUpgradeConfig.iOSAppStoreURL;
    if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)lastVersion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Strings.systemReminder message:@"您安装的App已是英荔商学院最新的版本" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:Strings.ok style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateAppVersion {
    
    NSString *versionStr = [NSString stringWithFormat:@"发现新版本V%@",self.storeVersion];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Strings.systemReminder message:versionStr preferredStyle:UIAlertControllerStyleAlert];
    
    WS(weakSelf);
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf gotoAppStore];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Strings.cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:action];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)wifiOnlySwitchValueChanged:(id)sender {
    if(!self.wifiOnlySwitch.isOn) {
        
        [[UIAlertController alloc] showInViewController:self title:[Strings cellularDownloadEnabledTitle] message:[Strings cellularDownloadEnabledMessage] preferredStyle:UIAlertControllerStyleAlert cancelButtonTitle:[Strings allow] destructiveButtonTitle:nil otherButtonsTitle:@[[Strings doNotAllow]] tapBlock:^(UIAlertController *alertController, UIAlertAction *alertAction, NSInteger buttonIndex) {
            // Allow
            if ( buttonIndex == 0 ) {
                [OEXInterface setDownloadOnlyOnWifiPref:self.wifiOnlySwitch.isOn];
            }
            // Don't Allow
            else if ( buttonIndex == 1 ) {
                [self.wifiOnlySwitch setOn:YES animated:YES];
            }
        } textFieldWithConfigurationHandler:nil];
    }
    else {
        [OEXInterface setDownloadOnlyOnWifiPref:self.wifiOnlySwitch.isOn];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [OEXStyles sharedStyles].standardStatusBarStyle;
}

@end

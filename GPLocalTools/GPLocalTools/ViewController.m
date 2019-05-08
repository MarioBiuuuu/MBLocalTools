//
/*******************************************************************************
    Copyright © 2019 Adrian. All rights reserved.

    File name:     ViewController.m
    Author:        Adrian

    Project name:  GPLocalTools

    Description:
    

    History:
            2019/5/8: File created.

********************************************************************************/
    

#import "ViewController.h"
#import "MBLocalizableTools.h"

@interface CustomePanel : NSOpenPanel
+(NSOpenPanel *)openPanelWithTitleMessage:(NSString *)ttMessage
                                setPrompt:(NSString *)prompt
                              chooseFiles:(BOOL)bChooseFiles
                        multipleSelection:(BOOL)bSelection
                        chooseDirectories:(BOOL)bChooseDirc
                        createDirectories:(BOOL)bCreateDirc
                          andDirectoryURL:(NSURL *)dirURL
                         AllowedFileTypes:(NSArray *)fileTypes;
@end

@implementation CustomePanel
+(NSOpenPanel *)openPanelWithTitleMessage:(NSString *)ttMessage
                                setPrompt:(NSString *)prompt
                              chooseFiles:(BOOL)bChooseFiles
                        multipleSelection:(BOOL)bSelection
                        chooseDirectories:(BOOL)bChooseDirc
                        createDirectories:(BOOL)bCreateDirc
                          andDirectoryURL:(NSURL *)dirURL
                         AllowedFileTypes:(NSArray *)fileTypes
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setPrompt:prompt];     // 设置默认选中按钮的显示（OK 、打开，Open ...）
    [panel setMessage: ttMessage];    // 设置面板上的提示信息
    [panel setCanChooseDirectories : bChooseDirc]; // 是否可以选择文件夹
    [panel setCanCreateDirectories : bCreateDirc]; // 是否可以创建文件夹
    [panel setCanChooseFiles : bChooseFiles];      // 是否可以选择文件
    [panel setAllowsMultipleSelection : bSelection]; // 是否可以多选
    [panel setAllowedFileTypes : fileTypes];        // 所能打开文件的后缀
    [panel setDirectoryURL:dirURL];                    // 打开的文件路径
    
    return panel;
}

@end

@interface ViewController () <MBLocalizableToolsDelegate>
@property (weak) IBOutlet NSTextField *originalFilePathLab;
@property (weak) IBOutlet NSTextField *savePathLab;
@property (unsafe_unretained) IBOutlet NSTextView *statusTv;
@property (weak) IBOutlet NSTextField *laungeCount;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *savePath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (IBAction)haha:(id)sender {
    if (self.filePath.length == 0) {
        self.statusTv.string = [self.statusTv.string stringByAppendingString:@"\n 请选择待解析的CSV文件"];
        return;
    }
    
    if (self.savePath.length == 0) {
        self.statusTv.string = [self.statusTv.string stringByAppendingString:@"\n 请选择解析后保存文件的路径"];
        return;
    }
    
    MBLocalizableTools *tool = [[MBLocalizableTools alloc] initWithSourceFilePath:self.filePath savePath:self.savePath languageCount:self.laungeCount.stringValue.intValue];
    tool.delegate = self;
    [tool beginParse];
}

- (IBAction)selectOriginalCsvFileAction:(id)sender {
    
    NSOpenPanel *panel = [CustomePanel
                          openPanelWithTitleMessage:@"Choose File" // folder 顶部提示
                          setPrompt:@"OK"                      // 文件选择确认键 显示内容（一般NULL随系统）
                          chooseFiles:YES                        // 是否可以选择文件（如果为NO 则只可以选择文件夹）
                          multipleSelection:NO                        // 是否可以多选
                          chooseDirectories:NO                         // 是否可以选择文件夹
                          createDirectories:NO                        // 是否可以创建文件夹
                          andDirectoryURL:NULL                       // 默认打开路径（桌面、 下载、...）
                          AllowedFileTypes:[NSArray arrayWithObjects:@"csv", nil] // 所能选择的文件类型
                          ];
    
    __weak typeof(self) weakSelf = self;
    [panel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (result == NSModalResponseOK) {
            strongSelf.filePath = [panel URLs].firstObject.path;
            strongSelf.originalFilePathLab.stringValue = strongSelf.filePath;
            NSLog(@"Click OK Choose files : %@", strongSelf.filePath);
        }else if(result == NSModalResponseCancel)
            NSLog(@"Click cancle");
    }];
    
}

- (IBAction)cahngeSaveFIlePath:(id)sender {
    NSOpenPanel *panel = [CustomePanel
                          openPanelWithTitleMessage:@"Choose File" // folder 顶部提示
                          setPrompt:@"OK"                      // 文件选择确认键 显示内容（一般NULL随系统）
                          chooseFiles:NO                        // 是否可以选择文件（如果为NO 则只可以选择文件夹）
                          multipleSelection:NO                        // 是否可以多选
                          chooseDirectories:YES                         // 是否可以选择文件夹
                          createDirectories:YES                        // 是否可以创建文件夹
                          andDirectoryURL:NULL                       // 默认打开路径（桌面、 下载、...）
                          AllowedFileTypes:[NSArray arrayWithObjects:@"csv", nil] // 所能选择的文件类型
                          ];
    
    __weak typeof(self) weakSelf = self;
    [panel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (result == NSModalResponseOK) {
            strongSelf.savePath = [panel URLs].firstObject.path;
            strongSelf.savePathLab.stringValue = strongSelf.savePath;
            NSLog(@"Click OK Choose files : %@", strongSelf.savePath);
        }else if(result == NSModalResponseCancel)
            NSLog(@"Click cancle");
    }];
}

- (void)localizableToolsEndWrite:(MBLocalizableTools *)tool {
    NSLog(@"%@", [NSString stringWithFormat:@"国际化后的文件被保存到：%@", self.savePath]);
    self.statusTv.string = [self.statusTv.string stringByAppendingString:[NSString stringWithFormat:@"\n 国际化后的文件被保存到：%@", self.savePath]];
}

- (void)localizableToolsEndParse:(MBLocalizableTools *)tool {
    NSLog( @"解析完成，正在写入文件...");
    self.statusTv.string = [self.statusTv.string stringByAppendingString:@"\n 解析完成，正在写入文件..."];

}

- (void)localizableToolsError:(MBLocalizableTools *)tool error:(NSError *)error {
    NSLog(@"%@， %@", @"错了啊", error.localizedDescription);
    self.statusTv.string = [self.statusTv.string stringByAppendingString:[NSString stringWithFormat:@"\n %@， %@", @"错了啊", error.localizedDescription]];
}

@end

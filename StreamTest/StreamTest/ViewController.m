//
//  ViewController.m
//  StreamTest
//
//  Created by BJ13041603-002 on 16/12/7.
//  Copyright © 2016年 liujianli. All rights reserved.
//

#import "ViewController.h"

#define HBUFC_BUFFER_SIZE       1024
uint8_t hbufc_file_buffer[HBUFC_BUFFER_SIZE];

#define readStreamPath  @"/Users/BJ13041603-002/Desktop/base.js"
#define writeStreamPath @"/Users/BJ13041603-002/Desktop/wr.txt"

@interface ViewController ()<NSStreamDelegate>
@property (weak, nonatomic) IBOutlet UIButton *readStreamBtn;
@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;
@property(nonatomic,strong) NSMutableData *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.data = [NSMutableData data];
}

- (UInt64)getFileSizeWithPath:(NSString *)path {
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary* fileAttr = [fileManager attributesOfItemAtPath:path error:&error];
    if(error) {
        NSLog(@"Fail getFileSizeWithPath.");
        return 0;
    }
    
    return [fileAttr fileSize];
}

- (IBAction)readStreamBtnClick:(UIButton *)sender {
    [self createStreamForFile:readStreamPath];
}

- (IBAction)outStreamBtnClick:(UIButton *)sender {
    [self createOutputStreamForFile:writeStreamPath];
}

-(void)createStreamForFile:(NSString *)path{
    self.inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
    [self.inputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
}

-(void)createOutputStreamForFile:(NSString *)path{
    self.outputStream = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
    [self.outputStream setDelegate:self];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
    [self.outputStream write:[self.data bytes] maxLength:self.data.length];
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.outputStream = nil;
}

#pragma mark - NSStreamDelegate
-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
    NSLog(@"%zd",eventCode);
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:{
            long bytes = [(NSInputStream *)stream read:hbufc_file_buffer maxLength:HBUFC_BUFFER_SIZE];
            while (bytes > 0) {
                NSData *data = [NSData dataWithBytes:hbufc_file_buffer length:bytes];
                //此处进行socket传送数据得操作
                [self.data appendData:data];
                bytes = [(NSInputStream *)stream read:hbufc_file_buffer maxLength:HBUFC_BUFFER_SIZE];
            }
        }
            break;
        case NSStreamEventEndEncountered:{
            // begin ===== 只是为了数据正确性测试
            NSString *dataStr = [[NSString alloc] initWithData:self.data encoding:(NSUTF8StringEncoding)];
            NSLog(@"%@===",dataStr);
            // end ==========================
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            stream = nil;
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

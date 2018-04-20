SiaoPods
============

## SiaoRequest
##### 使用文档
- 零. 类说明
    - 1. 此类为抽象类，必须继承使用，继承后重写如下方法，定义环境；
    - 2. 在app初始化时，必须设置online和test环境的URL；
eg:
SiaoSetValue(kSiaoRequestOnlineURL, @"http://10.79.40.81:8133/");
SiaoSetValue(kSiaoRequestTestURL, @"http://10.79.40.81:8133/");
- 一. path
- 1. path为完整路径(http://www.weibo.com/)则直接不用默认的网络环境(Online, Test)做请求(不拼接)
- 2. path为资源路径(timeline/category) 使用网络环境做拼接后请求
- 二. params
- 此为一个Block，需要返回一个字典，使用规范为, { retrun @{"title" : "weibo"}
- 三. finsh
此为一个回调Block，请求结束后不管成功与否都会调用这个回调
- 四.校验器
+ (SiaoResponseValidator *)requestValidator
返回一个默认的校验器，当有特殊reponse处理时，通过请求参数params的block里传入实例化的对象，key为 kRequestValidator
注意：当参数里有校验器的时候会使用传入的构造器，没有的时候使用默认校验器；
- 五. 集约型请求，子类需要重写的方法
- 1.请求方法，默认为get
- (HttpMethod)requestMethod;
- 2.请求路径，请参考文档第一套
- (NSString *)requestPath;
- 3.请求参数, 返回一个字典
- (NSDictionary *)generateParams;
- 六. 网络状态
- 1. + (NetworkReachabilityStatus)currentNetworkStatus; 返回枚举
- + (NSString *)networkStatusString; 返回文字

import 'package:quick_cat_client/app/data/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/comic_reader_page_controller.dart';

class NativeComicReaderView extends StatefulWidget {
  const NativeComicReaderView({super.key});

  @override
  State<NativeComicReaderView> createState() => _NativeComicReaderViewState();
}

class _NativeComicReaderViewState extends State<NativeComicReaderView> {
  static const platform = MethodChannel('com.quick_cat_client/comic_reader');
  bool _isInitialized = false;
  bool _isError = false;
  String? _errorMessage;
  int? _viewId;

  @override
  void initState() {
    super.initState();
    debugPrint('NativeComicReaderView initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('NativeComicReaderView didChangeDependencies');
  }

  Future<void> _initializeNativeView() async {
    try {
      debugPrint('Initializing native view with id: $_viewId');
      final controller = Get.find<ComicReaderPageController>();
      final screenSize = MediaQuery.of(context).size;

      if (controller.chapterPicList.isEmpty) {
        throw Exception('No images available');
      }

      debugPrint('Preparing images: ${controller.chapterPicList.length}');
      final images = controller.chapterPicList.map((pic) {
        final url = "https://image.htqhfqp.com/decode/${pic.comicsPic}";
        debugPrint('Image URL: $url, width: ${pic.width}, height: ${pic.high}');
        return {
          'url': url,
          'width': pic.width ?? 0,
          'height': pic.high ?? 0,
        };
      }).toList();

      debugPrint('Invoking native method with ${images.length} images');
      await platform.invokeMethod('initComicReader', {
        'images': images,
        'screenWidth': screenSize.width,
        'screenHeight': screenSize.height,
      });

      debugPrint('Native view initialized successfully');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing native view: $e');
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NativeComicReaderView build');
    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '加载失败，请重试',
              style: TextStyle(color: Colors.white),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: AndroidView(
        viewType: 'com.quick_cat_client/comic_reader_view',
        creationParams: const {},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          debugPrint('Platform view created with id: $id');
          _viewId = id;
          // 视图创建后立即初始化图片
          _initializeNativeView();
        },
      ),
    );
  }
}

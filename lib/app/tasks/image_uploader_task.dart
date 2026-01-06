import 'dart:async';
import 'package:quick_cat_client/app/model/cut_info.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:developer' as developer;

import 'image_uploader_helper.dart';

class ImageUploadTask {
  final _controller = StreamController<UploadState>.broadcast();
  bool _isUploading = false;

  Stream<UploadState> get stream => _controller.stream;

  Future<void> startUpload() async {
    if (_isUploading) {
      _controller.add(UploadState.error('Another upload is in progress'));
      return;
    }

    _isUploading = true;
    _controller.add(UploadState.selecting());

    try {
      // 1. Select image
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        _controller.add(UploadState.error('No image selected'));
        showToast(msg: '未选择图片');
        _isUploading = false;
        return;
      }

      _controller.add(UploadState.localPath(pickedFile.path));

      final formData = dio.FormData.fromMap({
        'upload': await dio.MultipartFile.fromFile(
          pickedFile.path,
          filename: pickedFile.name,
        ),
      });

      UploadImageRep? rep = await ApiRes.uploadImg(
        formData: formData,
        onError: (String error) {
          developer.log('uploadSingleImage error: $error',
              name: '_upload_image_err');
          _controller.add(UploadState.error(error));
          showTypeToast(msg: '图片上传异常');
        },
        onSendProgress: (count, total) {
          final progress = count / total;
          _controller.add(UploadState.progress(progress));
        },
      );

      // 4. Handle result
      if (rep != null) {
        _controller.add(UploadState.success(rep));
        showToast(msg: '上传成功');
      } else {
        _controller.add(UploadState.error('Upload failed'));
        showToast(msg: '上传失败');
      }
    } catch (e) {
      developer.log('uploadSingleImage error: $e', name: '_upload_image_err');
      _controller.add(UploadState.error('Image upload failed: $e'));
      showTypeToast(msg: '图片上传异常');
    } finally {
      _isUploading = false;
    }
  }

  void dispose() {
    _controller.close();
  }
}

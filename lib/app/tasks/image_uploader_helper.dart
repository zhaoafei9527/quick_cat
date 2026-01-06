import 'package:acgn_client/app/model/cut_info.dart';

class UploadState {
  final String? localPath; // Local path of the selected image
  final double? progress; // Upload progress (0.0 to 1.0)
  final UploadImageRep? result; // Upload result (if successful)
  final String? error; // Error message (if failed)
  final bool isCompleted; // Whether the upload is done
  final bool isCanceled; // Whether the upload was canceled

  UploadState({
    this.localPath,
    this.progress,
    this.result,
    this.error,
    this.isCanceled = false,
    this.isCompleted = false,
  });

  // Factory constructors for specific states
  factory UploadState.selecting() => UploadState();

  factory UploadState.localPath(String path) => UploadState(localPath: path);

  factory UploadState.progress(double progress) =>
      UploadState(progress: progress);

  factory UploadState.success(UploadImageRep result) =>
      UploadState(result: result, isCompleted: true);

  factory UploadState.error(String error) =>
      UploadState(error: error, isCompleted: true);

  factory UploadState.canceled() =>
      UploadState(isCanceled: true, isCompleted: true);
}

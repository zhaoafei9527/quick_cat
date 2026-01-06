package io.flutter.plugins;

import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.os.Environment;
import android.text.TextUtils;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class FileUtils {

    /**
     * 获取文件的mimetype
     */
    public static String getMimeType(String filePath) {
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        String mime = "text/plain";
        if (filePath != null) {
            try {
                mmr.setDataSource(filePath);
                mime = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE);
            } catch (IllegalStateException e) {
                return mime;
            } catch (IllegalArgumentException e) {
                return mime;
            } catch (RuntimeException e) {
                return mime;
            }
        }
        return mime;
    }

    /**
     * 获取视频时长
     */
    public static int getVideoDuration(String filePath) {

        String duration = "";
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        if (filePath != null) {
            try {
                FileInputStream inputStream = new FileInputStream(new File(filePath).getAbsolutePath());
                mmr.setDataSource(inputStream.getFD());
                duration = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
                if (TextUtils.isDigitsOnly(duration)) {
                    return  Integer.parseInt(duration) / 1000;
                }
            } catch (Exception e) {
                return 0;
            }
        }
        return 0;
    }

    /**
     * 获取视频分辨率
     */
    public static String getVideoResolution(String filePath) {
        StringBuffer buffer = new StringBuffer();
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        if (filePath != null) {
            try {
                FileInputStream inputStream = new FileInputStream(new File(filePath).getAbsolutePath());
                mmr.setDataSource(inputStream.getFD());
                buffer.append(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
                buffer.append("*");
                buffer.append(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
            } catch (Exception e) {
                return buffer.toString();
            }
        }
        return buffer.toString();
    }

    /**
     * 获取视频宽高比
     */
    public static String getVideoRatio(String filePath) {
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        if (filePath != null) {
            try {
                mmr.setDataSource(filePath);
                int width =
                        Integer.parseInt(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
                int height =
                        Integer.parseInt(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
                if (width > 0 && height > 0) {
                    return String.valueOf(Float.valueOf(width) / height);
                }
            } catch (Exception e) {
                return "0";
            }
        }
        return "0";
    }

    /**
     * 获取比特率
     * @param filePath
     * @return
     */
    public static String getVideoBitrate(String filePath) {
        MediaMetadataRetriever mmr = new MediaMetadataRetriever();
        try{
            mmr.setDataSource(filePath);
            String bitrate = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE);
            return bitrate;
        }catch (Exception e) {
            return "0";
        }
    }

    /**
     * 获取视频大小
     */
    public static int getVideoSize(String filePath) {
        int size = 0;
        File file = new File(filePath);
        if (file.exists()) {
            try {
                FileInputStream fis = new FileInputStream(file);
                size = fis.available();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return size;
    }

    /**
     * 获取并保存封面到本地
     */
    public static String saveCoverInLocal(String outputVideoPath) {
        final String imageSavePath = Environment.getExternalStorageDirectory().getAbsolutePath()
                + File.separator
                + "lkyDemo"
                + File.separator
                + "image";
        File filePath = new File(imageSavePath);
        if (!filePath.exists()) {
            filePath.mkdirs();
        }
        File file = new File(imageSavePath, System.currentTimeMillis() + ".jpg");
        FileOutputStream out = null;
        Bitmap btImage = getVideoThumb(outputVideoPath);
        try {
            out = new FileOutputStream(file);
            btImage.compress(Bitmap.CompressFormat.JPEG, 100, out);
            System.out.println("保存已经至" + Environment.getExternalStorageDirectory() + "下");
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        try {
            if (out != null) {
                out.flush();
                out.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (file.exists()) {
                return file.getAbsolutePath();
            }
            return "";
        }
    }

    /**
     * 获取视频文件截图
     *
     * @param path 视频文件的路径
     * @return Bitmap 返回获取的Bitmap
     */

    public static Bitmap getVideoThumb(String path) {

        MediaMetadataRetriever media = new MediaMetadataRetriever();

        media.setDataSource(path);

        return media.getFrameAtTime();
    }
}

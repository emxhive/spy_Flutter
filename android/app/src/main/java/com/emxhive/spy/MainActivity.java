package com.emxhive.spy;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {


    private static final String CHANNEL = "com.emxhive.spy/csv-share";

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // This method is invoked on the main thread.

                            if (call.method.equals("shareCSV")) {
                                result.success(shareCSV(call.argument("path")));
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private String shareCSV(String path) {
//        Intent intent = new Intent(Intent.ACTION_SEND);
//        Context context = ContextWrapper(getApplicationContext());
//        File file = new File(path);
//        Log.d("ENV", Environment.getExternalStorageDirectory().getPath());
//        Log.d("CONTEXT", getFilesDir().getPath());
////        intent.putExtra(Intent.EXTRA_STREAM, );
//
//        intent.setData(getUriForFile(this, "com.emxhive.spy.fileprovider", file));
//        startActivity(Intent.createChooser(intent, "Share CSV"));
//        return file.getPath();
        return "";
    }

}

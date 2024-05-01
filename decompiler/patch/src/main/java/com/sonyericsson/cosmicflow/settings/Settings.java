package com.sonyericsson.cosmicflow.settings;

import android.os.Bundle;
import android.preference.PreferenceActivity;
import com.sonyericsson.cosmicflow.R;

public class Settings extends PreferenceActivity {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.settings);
    }

    @Override
    protected void onResume() {
        super.onResume();

    }

    @Override
    protected void onPause() {
        super.onPause();
    }


}
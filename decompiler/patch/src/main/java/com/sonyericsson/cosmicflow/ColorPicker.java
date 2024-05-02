// 
// Decompiled by Procyon v0.6.0
// 

package com.sonyericsson.cosmicflow;

import android.content.SharedPreferences;
import android.content.Context;

import android.content.res.Configuration;
import android.preference.PreferenceManager;

import static com.sonyericsson.cosmicflow.ColorInfo.extract;
import static com.sonyericsson.cosmicflow.ColorInfo.fromHexString;

public class ColorPicker implements SharedPreferences.OnSharedPreferenceChangeListener
 {
    private float[][] mCurrentColor;
    private SharedPreferences preferences;
     public boolean isDarkMode = true;
     public boolean bgBloomDisable = true;
     private Context ctx;

     public ColorPicker(final Context context) {
        ctx = context.getApplicationContext();
        this.mCurrentColor = ColorInfo.extract(ColorInfo.Amber.color);
        preferences = PreferenceManager.getDefaultSharedPreferences(context);
        preferences.registerOnSharedPreferenceChangeListener(this);
        loadFromSettings();
    }

    @SuppressWarnings("deprecation")
    public void loadFromSettings(){
        if (preferences.getBoolean("customColors",false)) {
            String primaryColor = preferences.getString("primaryColor", "004161");
            String accentColor = preferences.getString("accentColor", "004161");
            if (validate(primaryColor)&&validate(accentColor)) mCurrentColor = new float[][] {
                    fromHexString(primaryColor),
                    fromHexString(accentColor)};
        } else {
            loadPresetColor();
        }
        if (preferences.getBoolean("autoDark",true)){
            isDarkMode = checkDarkMode();
        } else {
            isDarkMode = preferences.getBoolean("alwaysDark",true);
        }
        bgBloomDisable = preferences.getBoolean("bgBloomDisable", true);

    }
     private boolean validate(String s){
         if (s.length()!=6) return false;
         return s.matches("-?[0-9a-fA-F]+");
     }

     private boolean checkDarkMode(){
         int nightModeFlags =
                 ctx.getResources().getConfiguration().uiMode &
                         Configuration.UI_MODE_NIGHT_MASK;
         return !(nightModeFlags == Configuration.UI_MODE_NIGHT_NO);
     }
     private void loadPresetColor(){
         String switcher = preferences.getString("waveStyle","1");
         switch (switcher ){
             case "Emerald":
                 mCurrentColor = extract(ColorInfo.Emerald.color);
                 break;
             case "Sapphire":
                 mCurrentColor = extract(ColorInfo.Sapphire.color);
                 break;
             case "Gold":
                 mCurrentColor = extract(ColorInfo.Gold.color);
                 break;
             case "Ruby":
                 mCurrentColor = extract(ColorInfo.Ruby.color);
                 break;
             case "Amethyst":
                 mCurrentColor = extract(ColorInfo.Amethyst.color);
                 break;
             case "Amber":
                 mCurrentColor = extract(ColorInfo.Amber.color);
                 break;
             //case "Monet":
             default:
                 int primaryColor, accentColor;
                 if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                     primaryColor = ctx.getColor(R.color.primary); //For light theme we need to use different colors
                     accentColor =  ctx.getColor(R.color.accent);
                 } else {
                     primaryColor = ctx.getResources().getColor(R.color.primary);
                     accentColor = ctx.getResources().getColor(R.color.accent);
                 }
                 mCurrentColor = extract(primaryColor,  accentColor);
                 break;
         }
     }
    public void destroy(){}
      @Override
      
     public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
         loadFromSettings();
     }
    
    public float[] getPrimaryColor() {
        return this.mCurrentColor[0].clone();
    }
    
    public float[] getSecondaryColor() {
        return this.mCurrentColor[1].clone();
    }
}

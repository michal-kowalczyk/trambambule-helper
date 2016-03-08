package pl.ekk.mkk.djinnidemo;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.NumberPicker;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {
    private TextView messageFromCppTextView;
    private NumberPicker minValueNumberPicker;
    private NumberPicker maxValueNumberPicker;
    private Button generateRandomButton;
    private TextView randomValueTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        initializeControls();

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void initializeControls() {
        String[] allRandomVals = new String[100];
        for (int i = 0; i < 100; ++i) {
            allRandomVals[i] = Integer.valueOf(i).toString();
        }

        minValueNumberPicker = (NumberPicker) findViewById(R.id.minValueNumberPicker);
        minValueNumberPicker.setDisplayedValues(allRandomVals);
        minValueNumberPicker.setMinValue(0);
        minValueNumberPicker.setMaxValue(99);
        minValueNumberPicker.setValue(0);

        maxValueNumberPicker = (NumberPicker) findViewById(R.id.maxValueNumberPicker);
        maxValueNumberPicker.setDisplayedValues(allRandomVals);
        maxValueNumberPicker.setMinValue(0);
        maxValueNumberPicker.setMaxValue(99);
        maxValueNumberPicker.setValue(2);

        generateRandomButton = (Button) findViewById(R.id.generateRandomButton);

        randomValueTextView = (TextView) findViewById(R.id.randomValueTextView);
        randomValueTextView.setText("");

        messageFromCppTextView = (TextView) findViewById(R.id.messageFromCppTextView);
        messageFromCppTextView.setText(Test.test());

        final RandomGenerator randGen = Test.getRandomGenerator();
        generateRandomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int randomVal = randGen.getRandom(new RandomGeneratorParams() {
                    @Override
                    public int getMinBound() {
                        return minValueNumberPicker.getValue();
                    }

                    @Override
                    public int getMaxBound() {
                        return maxValueNumberPicker.getValue();
                    }
                });
                randomValueTextView.setText(Integer.valueOf(randomVal).toString());
            }
        });
    }

    static {
        System.loadLibrary("cpp_jni");
    }
}

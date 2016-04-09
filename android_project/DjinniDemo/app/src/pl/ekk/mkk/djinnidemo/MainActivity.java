package pl.ekk.mkk.djinnidemo;

import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {
    private Button decrementTotalPointsButton;
    private Button incrementTotalPointsButton;
    private TextView totalPointsTextView;
    private Button resetButton;
    private ViewGroup viewGroup;

    private final static int leftMargin = 5;
    private final static int topMargin = 5;
    private final static int rightMargin = 5;
    private final static int bottomMargin = 5;
    private final static int spacing = 1;

    private final static int initialTotalPointsCount = 8;
    private final static int minTotalPoints = 3;
    private final static int maxTotalPoints = 30;
    private int totalPoints = initialTotalPointsCount;
    private Integer viewGroupWidth;
    private Integer viewGroupHeight;

    private int redDiceId;
    private int blueDiceId;

    private ImageView[] redPoints;
    private ImageView[] bluePoints;

    static {
        System.loadLibrary("cpp_jni");
    }

    private Game game;

    private void registerResetButtonListener() {
        resetButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                UISettings uiSettings = new UISettings(leftMargin, topMargin,
                        viewGroupWidth - rightMargin, viewGroupHeight - bottomMargin, spacing);
                game = Game.create(uiSettings, totalPoints);
                game.setRepositionListener(new RepositionListener() {
                    @Override
                    public void onReposition(RepositionEvent e) {
                        ImageView[] pointsArray = (e.getTeam() == Team.RED ? redPoints : bluePoints);
                        ImageView iv = pointsArray[e.getPoint()];
                        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) iv.getLayoutParams();
                        lp.leftMargin = e.getX();
                        lp.topMargin = e.getY();
                        iv.setLayoutParams(lp);
                    }
                });

                int pointSize = game.getPointSize();
                viewGroup.removeAllViews();
                createImgViews(pointSize);

                game.startGame();
            }
        });
    }

    private void registerSwipes() {
        viewGroup.setOnTouchListener(new OnSwipeTouchListener(MainActivity.this) {
            public void onSwipeTop(int avgX) {
                if (game == null) {
                    return;
                }
                if (avgX > viewGroupWidth / 2) {
                    game.gainPoint(Team.BLUE);
                } else {
                    game.losePoint(Team.RED);
                }
            }

            public void onSwipeBottom(int avgX) {
                if (game == null) {
                    return;
                }
                if (avgX > viewGroupWidth / 2) {
                    game.losePoint(Team.BLUE);
                } else {
                    game.gainPoint(Team.RED);
                }
            }
        });
    }

    private void createImgViews(int pointSize) {
        redPoints = new ImageView[totalPoints];
        bluePoints = new ImageView[totalPoints];

        for (int i = 0; i < totalPoints; ++i) {
            ImageView imageView = new ImageView(MainActivity.this);
            imageView.setImageResource(redDiceId);
            viewGroup.addView(imageView, new FrameLayout.LayoutParams(pointSize, pointSize));
            redPoints[i] = imageView;

            imageView = new ImageView(MainActivity.this);
            imageView.setImageResource(blueDiceId);
            viewGroup.addView(imageView, new FrameLayout.LayoutParams(pointSize, pointSize));
            bluePoints[i] = imageView;
        }

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        redDiceId = getResources().getIdentifier("reddice", "drawable", getPackageName());
        blueDiceId = getResources().getIdentifier("bluedice", "drawable", getPackageName());

        decrementTotalPointsButton = (Button) findViewById(R.id.decrementTotalPointsButton);
        incrementTotalPointsButton = (Button) findViewById(R.id.incrementTotalPointsButton);
        totalPointsTextView = (TextView) findViewById(R.id.totalPointsTextView);
        resetButton = (Button) findViewById(R.id.resetButton);
        viewGroup = (ViewGroup) findViewById(R.id.pointsView);

        final ViewTreeObserver observer = viewGroup.getViewTreeObserver();
        observer.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                // TODO Auto-generated method stub
                viewGroupWidth = viewGroup.getWidth();
                viewGroupHeight = viewGroup.getHeight();
            }
        });

        decrementTotalPointsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (totalPoints > minTotalPoints) {
                    --totalPoints;
                    updateTotalPointsTextView();
                }
            }
        });

        incrementTotalPointsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (totalPoints < maxTotalPoints) {
                    ++totalPoints;
                    updateTotalPointsTextView();
                }
            }
        });

        updateTotalPointsTextView();
        registerResetButtonListener();
        registerSwipes();
    }

    private void updateTotalPointsTextView() {
        totalPointsTextView.setText(Integer.valueOf(totalPoints).toString());
    }

    public class OnSwipeTouchListener implements View.OnTouchListener {

        private final GestureDetector gestureDetector;

        public OnSwipeTouchListener (Context ctx){
            gestureDetector = new GestureDetector(ctx, new GestureListener());
        }

        @Override
        public boolean onTouch(View v, MotionEvent event) {
            return gestureDetector.onTouchEvent(event);
        }

        private final class GestureListener extends GestureDetector.SimpleOnGestureListener {
            private static final int SWIPE_THRESHOLD = 50;
            private static final int SWIPE_VELOCITY_THRESHOLD = 10;

            @Override
            public boolean onDown(MotionEvent e) {
                return true;
            }

            @Override
            public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
                boolean result = false;
                try {
                    float diffY = e2.getY() - e1.getY();
                    float avgX = (e2.getX() + e1.getX()) / 2;
                    if (Math.abs(diffY) > SWIPE_THRESHOLD && Math.abs(velocityY) > SWIPE_VELOCITY_THRESHOLD) {
                        if (diffY > 0) {
                            onSwipeBottom((int)avgX);
                        } else {
                            onSwipeTop((int)avgX);
                        }
                    }
                    result = true;

                } catch (Exception exception) {
                    exception.printStackTrace();
                }
                return result;
            }
        }

        public void onSwipeBottom(int avgX) { }

        public void onSwipeTop(int avgX) { }
    }
}

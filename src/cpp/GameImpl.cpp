#include "Game.hpp"
#include "RepositionEvent.hpp"
#include "RepositionListener.hpp"
#include "UISettings.hpp"
#include <memory>

namespace djinnidemo {

class GameImpl : public Game {
 public:
  GameImpl(const UISettings& ui, int32_t totalPoints)
    : totalPoints_(totalPoints),
      pointSize_((ui.bottom - ui.top) / (totalPoints + 1) - ui.spacing),
      redPt0X_(ui.left),
      redPt0Y_(ui.top),
      bluePt0X_(ui.right - pointSize_),
      bluePt0Y_(ui.bottom - pointSize_),
      redShift_(pointSize_ + ui.spacing),
      blueShift_(-redShift_),
      redPoints_(0),
      bluePoints_(0) {
  }

  int32_t getPointSize() {
    return pointSize_;
  }

  void setRepositionListener(const std::shared_ptr<RepositionListener>& l) {
    listener_ = l;
  }
  
  void startGame() {
    for (int32_t i = 0; i < totalPoints_; ++i) {
      RepositionEvent e1(Team::RED, i, redPt0X_, i * redShift_ + redPt0Y_);
      listener_->onReposition(e1);
      RepositionEvent e2(Team::BLUE, i, bluePt0X_, i * blueShift_ + bluePt0Y_);
      listener_->onReposition(e2);
    }
  }

  void gainPoint(Team t) {
    if (Team::RED == t) {
      gainPt(t, redPoints_, redPt0X_, redPt0Y_, redShift_);
    } else {
      gainPt(t, bluePoints_, bluePt0X_, bluePt0Y_, blueShift_);
    }
  }

  void losePoint(Team t) {
    if (Team::RED == t) {
      losePt(t, redPoints_, redPt0X_, redPt0Y_, redShift_);
    } else {
      losePt(t, bluePoints_, bluePt0X_, bluePt0Y_, blueShift_);
    }
  }

 private:
  void gainPt(Team t, int32_t& points, int32_t pt0X, int32_t pt0Y, int32_t shift) {
    if (points >= totalPoints_) {
      return;
    }
    ++points;
    int32_t pointId = totalPoints_ - points;
    int32_t pos = pointId + 1;
    RepositionEvent e(t, pointId, pt0X, pos * shift + pt0Y);
    listener_->onReposition(e);
  }

  void losePt(Team t, int32_t& points, int32_t pt0X, int32_t pt0Y, int32_t shift) {
    if (points <= 0) {
      return;
    }
    int32_t pointId = totalPoints_ - points;
    int32_t pos = pointId;
    --points;
    RepositionEvent e(t, pointId, pt0X, pos * shift + pt0Y);
    listener_->onReposition(e);
  }

  const int32_t totalPoints_;

  std::shared_ptr<RepositionListener> listener_;

  int32_t pointSize_;
  int32_t redPt0X_;
  int32_t redPt0Y_;
  int32_t bluePt0X_;
  int32_t bluePt0Y_;
  int32_t redShift_;
  int32_t blueShift_;

  int32_t redPoints_;
  int32_t bluePoints_;
};

std::shared_ptr<Game> Game::create(const UISettings& ui, int32_t totalPoints) {
  return std::make_shared<GameImpl>(ui, totalPoints);
}

}  // namespace djinnidemo

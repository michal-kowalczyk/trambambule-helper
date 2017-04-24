#include "Game.hpp"
#include "PointCreationEvent.hpp"
#include "PointRepositionEvent.hpp"
#include "PointListener.hpp"
#include "PointsCanvasMetrics.hpp"
#include <memory>
#include <string>

namespace djinnidemo
{

class GameImpl : public Game
{
public:
  GameImpl(const PointsCanvasMetrics& ui,
           const int32_t totalPoints,
           const std::shared_ptr<PointListener>& l)
    : totalPoints_(totalPoints),
      listener_(l),
      pointSize_((ui.bottom - ui.top) / (totalPoints + 1) - ui.spacing),
      redPt0X_(ui.left),
      redPt0Y_(ui.top),
      bluePt0X_(ui.right - pointSize_),
      bluePt0Y_(ui.bottom - pointSize_),
      redShift_(pointSize_ + ui.spacing),
      blueShift_(-redShift_),
      redPoints_(0),
      bluePoints_(0) {
    createPoints(pointSize_);
    std::string test = std::to_string(0);
  }

  void gainPoint(Team t) override
  {
    if (Team::RED == t)
    {
      gainPt(t, redPoints_, redPt0X_, redPt0Y_, redShift_);
    }
    else
    {
      gainPt(t, bluePoints_, bluePt0X_, bluePt0Y_, blueShift_);
    }
  }

  void losePoint(Team t) override
  {
    if (Team::RED == t)
    {
      losePt(t, redPoints_, redPt0X_, redPt0Y_, redShift_);
    }
    else
    {
      losePt(t, bluePoints_, bluePt0X_, bluePt0Y_, blueShift_);
    }
  }

 private:
  void createPoints(const int32_t pointSize)
  {
    for (int32_t i = 0; i < totalPoints_; ++i)
    {
      PointCreationEvent e1(Team::RED,
          i, redPt0X_, i * redShift_ + redPt0Y_, pointSize);
      listener_->onCreation(e1);
      PointCreationEvent e2(Team::BLUE,
          i, bluePt0X_, i * blueShift_ + bluePt0Y_, pointSize);
      listener_->onCreation(e2);
    }
  }

  void gainPt(const Team t,
              int32_t& points,
              const int32_t pt0X,
              const int32_t pt0Y,
              const int32_t shift)
  {
    if (points >= totalPoints_)
    {
      return;
    }
    ++points;
    const int32_t pointId = totalPoints_ - points;
    const int32_t pos = pointId + 1;
    const PointRepositionEvent e(t, pointId, pt0X, pos * shift + pt0Y);
    listener_->onReposition(e);
  }

  void losePt(const Team t,
              int32_t& points,
              const int32_t pt0X,
              const int32_t pt0Y,
              const int32_t shift)
  {
    if (points <= 0)
    {
      return;
    }
    const int32_t pointId = totalPoints_ - points;
    const int32_t pos = pointId;
    --points;
    PointRepositionEvent e(t, pointId, pt0X, pos * shift + pt0Y);
    listener_->onReposition(e);
  }

  const int32_t totalPoints_;

  const std::shared_ptr<PointListener> listener_;

  const int32_t pointSize_;
  const int32_t redPt0X_;
  const int32_t redPt0Y_;
  const int32_t bluePt0X_;
  const int32_t bluePt0Y_;
  const int32_t redShift_;
  const int32_t blueShift_;

  int32_t redPoints_;
  int32_t bluePoints_;
};

std::shared_ptr<Game> Game::create(const PointsCanvasMetrics& metrics,
                                   int32_t totalPoints,
                                   const std::shared_ptr<PointListener>& listener)
{
  return std::make_shared<GameImpl>(metrics, totalPoints, listener);
}

}  // namespace djinnidemo

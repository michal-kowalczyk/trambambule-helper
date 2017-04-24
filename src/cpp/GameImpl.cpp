#include <Game.hpp>
#include <PointCreationEvent.hpp>
#include <PointRepositionEvent.hpp>
#include <PointListener.hpp>
#include <PointsCanvasMetrics.hpp>

#include <memory>
#include <string>

namespace djinnidemo
{
namespace
{

class TeamPoints
{
public:
  TeamPoints(const Team team,
             const int32_t firstPointX,
             const int32_t firstPointY,
             const int32_t pointsShift)
  : score(0)
  , team_(team)
  , pt0X_(firstPointX)
  , pt0Y_(firstPointY)
  , shift_(pointsShift)
  {
    // do nothing
  }

  PointCreationEvent createEvent(const int32_t pointId, const int32_t pointSize) const
  {
    return PointCreationEvent(team_, pointId, pt0X_, pointId * shift_ + pt0Y_, pointSize);
  }

  PointRepositionEvent repositionEvent(const int32_t pointId, const int32_t newPosition) const
  {
    return PointRepositionEvent(team_, pointId, pt0X_, newPosition * shift_ + pt0Y_);
  }

public:
  int32_t score;

private:
  const Team team_;
  const int32_t pt0X_;
  const int32_t pt0Y_;
  const int32_t shift_;
};

}  // unnamed namespace

class GameImpl : public Game
{
public:
  GameImpl(const PointsCanvasMetrics& ui,
           const int32_t totalPoints,
           const std::shared_ptr<PointListener>& listener)
    : totalPoints_(totalPoints)
    , listener_(listener)
    , pointSize_((ui.bottom - ui.top) / (totalPoints + 1) - ui.spacing)
    , redPoints_(Team::RED, ui.left, ui.top, pointSize_ + ui.spacing)
    , bluePoints_(Team::BLUE, ui.right - pointSize_, ui.bottom - pointSize_, -(pointSize_ + ui.spacing))
  {
    createPoints();
  }

public:  // from Game
  void gainPoint(Team team) override
  {
    gainPt(Team::RED == team ? redPoints_ : bluePoints_);
  }

  void losePoint(Team team) override
  {
    losePt(Team::RED == team ? redPoints_ : bluePoints_);
  }

private:
  void createPoints()
  {
    for (int32_t i = 0; i < totalPoints_; ++i)
    {
      listener_->onCreation(redPoints_.createEvent(i, pointSize_));
      listener_->onCreation(bluePoints_.createEvent(i, pointSize_));
    }
  }

  void gainPt(TeamPoints& points)
  {
    if (points.score >= totalPoints_)
    {
      return;
    }
    ++points.score;
    const int32_t pointId = totalPoints_ - points.score;
    const int32_t newPosition = pointId + 1;
    listener_->onReposition(points.repositionEvent(pointId, newPosition));
  }

  void losePt(TeamPoints& points)
  {
    if (points.score <= 0)
    {
      return;
    }
    const int32_t pointId = totalPoints_ - points.score;
    const int32_t newPosition = pointId;
    --points.score;
    listener_->onReposition(points.repositionEvent(pointId, newPosition));
  }

private:
  const int32_t totalPoints_;
  const std::shared_ptr<PointListener> listener_;

  const int32_t pointSize_;

  TeamPoints redPoints_;
  TeamPoints bluePoints_;
};

std::shared_ptr<Game> Game::create(const PointsCanvasMetrics& metrics,
                                   int32_t totalPoints,
                                   const std::shared_ptr<PointListener>& listener)
{
  return std::make_shared<GameImpl>(metrics, totalPoints, listener);
}

}  // namespace djinnidemo

#pragma once

#include <cstdlib>
#include "RandomGenerator.hpp"
#include "RandomGeneratorParams.hpp"

namespace djinnidemo {

class RandomGeneratorImpl : public RandomGenerator {
public:
  int32_t getRandom(const std::shared_ptr<RandomGeneratorParams> & params) {
    int32_t min = params->getMinBound();
    int32_t max = params->getMaxBound();
    return (rand() % (max - min)) - min;
  }
};

}  // namespace djinnidemo

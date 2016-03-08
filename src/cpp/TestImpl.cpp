#include "Test.hpp"
#include "RandomGeneratorImpl.hpp"

namespace djinnidemo {

std::string Test::test() {
  return "Hello Djinni!";
}

std::shared_ptr<RandomGenerator> Test::getRandomGenerator() {
  return std::make_shared<RandomGeneratorImpl>();
}

}  // namespace djinnidemo

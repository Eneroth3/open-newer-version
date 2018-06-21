#include <SketchUpAPI/common.h>
#include <SketchUpAPI/initialize.h>
#include <SketchUpAPI/model/model.h>
#include <unordered_map>
#include <string>// std::string, std::stoi

// - Source path
// - Target path
// - SketchUp version (without leading 20)
int main(int argc, char* argv[]) {
  if (argc != 4) return 1;

  const char* source = argv[1];
  const char* target = argv[2];
  int version_name = std::stoi(argv[3]);

  // REVIEW: Must be a way to simply append number to "SUModelVersion_SU" string
  // and get enum from its string name.
  const std::unordered_map<int, SUModelVersion> versions = {
    {3,SUModelVersion_SU3},
    {4,SUModelVersion_SU4},
    {5,SUModelVersion_SU5},
    {6,SUModelVersion_SU6},
    {7,SUModelVersion_SU7},
    {8,SUModelVersion_SU8},
    {13,SUModelVersion_SU2013},
    {14,SUModelVersion_SU2014},
    {15,SUModelVersion_SU2015},
    {16,SUModelVersion_SU2016},
    {17,SUModelVersion_SU2017},
    {18,SUModelVersion_SU2018}
  };
  enum SUModelVersion version = versions.at(version_name);

  SUInitialize();

  SUModelRef model = SU_INVALID;
  SUResult res = SUModelCreateFromFile(&model, source);
  if (res != SU_ERROR_NONE) return 1;
  SUModelSaveToFileWithVersion(model, target, version);

  SUModelRelease(&model);
  SUTerminate();
  // TODO: Should version, versions, source and target be released too?
  return 0;
}

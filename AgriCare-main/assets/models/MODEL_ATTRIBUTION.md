# Bundled Screening Model

**File:** `arecanut_model.tflite` (MobileNet-based image classifier, ~11MB)
**Labels:** `plant_labels.txt` (38 classes)

## Source

Taken as-is from [obeshor/Plant-Diseases-Detector](https://github.com/obeshor/Plant-Diseases-Detector)
(`GreenDoctor/app/src/main/assets/plant_disease_model.tflite`), © 2019 Yannick Serge Obam,
licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## What it actually is

This is a MobileNet classifier trained on the **PlantVillage** dataset — 38 classes across
apple, blueberry, cherry, corn, grape, orange, peach, pepper, potato, raspberry, soybean,
squash, strawberry and tomato. **It was never trained on arecanut and has no arecanut
disease classes.** No public arecanut-specific TFLite model exists as of this writing —
the project spec's plan (train EfficientNet-B0 on a custom-collected arecanut dataset) is
still the correct path to a real classifier.

## How it's used here

`lib/services/diagnostic_service.dart` runs this model for its one genuinely transferable
signal — a leaf's general **healthy vs. diseased** visual pattern — and aggregates the
38-way softmax into that binary signal plus a confidence score. It does **not** claim to
identify which of the 6 arecanut diseases is present from the model output; that part
still uses the existing weighted-random/demo selection, with severity derived from the
model's real diseased-confidence rather than being fully random. Reports produced this way
are flagged in the UI as coming from the on-device screening model, distinct from full demo
mode (used automatically when no interpreter is available, e.g. on web).

Replace this file with a properly trained arecanut model when one exists — see
`Training Code Outline` in the project spec (Section 3.1) for the intended training setup.

## Input / output contract

- Input: `224×224×3` RGB, `float32`, normalized to `[0, 1]` (no mean subtraction)
- Output: `float32[1, 38]` softmax over `plant_labels.txt`

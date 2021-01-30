# tetris-puzzle
Image Processing Project - UniMiB

The goal of the project is to detect and classify tetris pieces (tetromini) from the scene and process them properly according to the scheme to compose the puzzle.

Input is made up by two images:
| Scheme | Scene |
|--------|-------|
|<img src="https://github.com/pietroepis/tetris-puzzle/blob/main/schemes/S06.jpg" width="300"/> | <img src="https://github.com/pietroepis/tetris-puzzle/blob/main/scenes/P10.jpg" width="300"/>|

Following assumptions on scene images have been made:
- Illumination and shadows must be regular, and anyway similar to those shown in example images
- Borders must be visible enough, continuous and black
- Background must be white or anyway light

Following assumptions on scheme images have been made:
- Tetromini must be thoroughly visible and not cut from the margins of the image
- Tetromini may be really close to each other, but they can't overlap
- Background color and texture must be the same shown in training set
- Illumination and perspective should be similar to those shown in training set
- It's not mandatory for a tetromino to always have the same color (classification is based on geometrical properties, not colors)

**How to execute**
You can launch the script from `main.m`, anyway you should previously execute `training.m` that takes care of training the two classifiers (Bayesian & KNN)\
Input images can be specified by setting the values of `scheme_name` and `scene_name` variables, at the top of `main.m`.

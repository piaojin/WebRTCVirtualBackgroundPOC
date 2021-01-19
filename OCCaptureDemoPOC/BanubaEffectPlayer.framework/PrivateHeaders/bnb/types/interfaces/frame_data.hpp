/// \file
/// \addtogroup Types
/// @{
///
// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from types.djinni

#pragma once

#include <bnb/types/full_image.hpp>
#include <bnb/utils/defs.hpp>
#include <cstdint>
#include <memory>
#include <vector>

namespace bnb { namespace interfaces {

class frx_recognition_result;
enum class face_data_source;
struct acne_regions;
struct action_units_data;
struct depth_map;
struct external_face_data;
struct eyes_state;
struct lips_shine_mask;
struct transformed_mask_byte;
struct transformed_mask_gpu;

/**
 * getters throw exceptions when data are not available
 * android NNs usually output gpu masks
 */
class BNB_EXPORT frame_data {
public:
    virtual ~frame_data() {}

    /** Creates empty `FrameData`. Use `add*` function to fill it.  */
    static std::shared_ptr<frame_data> create();

    virtual std::vector<float> get_full_img_transform() = 0;

    /** Get frx_recognition_result or null if not exists */
    virtual std::shared_ptr<frx_recognition_result> get_frx_recognition_result() = 0;

    virtual action_units_data get_action_units() = 0;

    virtual acne_regions get_acne_regions() = 0;

    virtual bool get_is_smile() = 0;

    virtual bool get_is_mouth_open() = 0;

    virtual bool get_is_brows_raised() = 0;

    virtual bool get_is_brows_shifted() = 0;

    virtual bool get_is_wear_glasses() = 0;

    virtual float get_is_male() = 0;

    virtual float get_ruler() = 0;

    virtual eyes_state get_eyes_state() = 0;

    virtual transformed_mask_byte get_background() = 0;

    virtual transformed_mask_gpu get_background_gpu() = 0;

    virtual transformed_mask_byte get_hair() = 0;

    virtual transformed_mask_gpu get_hair_gpu() = 0;

    virtual transformed_mask_byte get_skin() = 0;

    virtual transformed_mask_gpu get_skin_gpu() = 0;

    virtual transformed_mask_byte get_lips() = 0;

    virtual transformed_mask_gpu get_lips_gpu() = 0;

    virtual transformed_mask_byte get_occlusion() = 0;

    virtual transformed_mask_byte get_body() = 0;

    virtual lips_shine_mask get_lips_shine() = 0;

    virtual void add_full_img(::bnb::full_image_t img) = 0;

    virtual void add_background(const transformed_mask_byte & mask) = 0;

    virtual void add_external_face_data(face_data_source source, const std::vector<external_face_data> & data) = 0;

    virtual void add_depth_map(const depth_map & depth_map) = 0;

    virtual void add_frame_number(int64_t frame_number) = 0;

    virtual void add_action_units_data(const action_units_data & action_units) = 0;

    /** color to use for current ferature CPU calculations. */
    virtual void add_feature_color(float r, float g, float b, float a) = 0;
};

} }  // namespace bnb::interfaces
/// @}

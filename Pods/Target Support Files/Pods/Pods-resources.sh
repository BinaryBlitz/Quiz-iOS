#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
          install_resource "DBCamera/DBCamera/Resources/DBCameraImages.xcassets"
                    install_resource "DBCamera/DBCamera/Localizations/en.lproj"
                    install_resource "DBCamera/DBCamera/Localizations/es.lproj"
                    install_resource "DBCamera/DBCamera/Localizations/it.lproj"
                    install_resource "DBCamera/DBCamera/Localizations/pt.lproj"
                    install_resource "DBCamera/DBCamera/Localizations/ru.lproj"
                    install_resource "DBCamera/DBCamera/Localizations/sv-SE.lproj"
                    install_resource "DBCamera/DBCamera/Localizations/tr.lproj"
                    install_resource "DBCamera/DBCamera/Filters/1977.acv"
                    install_resource "DBCamera/DBCamera/Filters/amaro.acv"
                    install_resource "DBCamera/DBCamera/Filters/Hudson.acv"
                    install_resource "DBCamera/DBCamera/Filters/mayfair.acv"
                    install_resource "DBCamera/DBCamera/Filters/Nashville.acv"
                    install_resource "DBCamera/DBCamera/Filters/Valencia.acv"
                    install_resource "DBCamera/DBCamera/Filters/Vignette.acv"
                    install_resource "DateTools/DateTools/DateTools.bundle"
                    install_resource "GPUImage/framework/Resources/lookup.png"
                    install_resource "GPUImage/framework/Resources/lookup_amatorka.png"
                    install_resource "GPUImage/framework/Resources/lookup_miss_etikate.png"
                    install_resource "GPUImage/framework/Resources/lookup_soft_elegance_1.png"
                    install_resource "GPUImage/framework/Resources/lookup_soft_elegance_2.png"
                    install_resource "JSQMessagesViewController/JSQMessagesViewController/Assets/JSQMessagesAssets.bundle"
                    install_resource "JSQMessagesViewController/JSQMessagesViewController/Controllers/JSQMessagesViewController.xib"
                    install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellIncoming.xib"
                    install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesCollectionViewCellOutgoing.xib"
                    install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesLoadEarlierHeaderView.xib"
                    install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesToolbarContentView.xib"
                    install_resource "JSQMessagesViewController/JSQMessagesViewController/Views/JSQMessagesTypingIndicatorFooterView.xib"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140628105322170_drop_and_clean_case_indent_dates_uniques.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140628114921198_remove_creator_id_from_tombstone_wipe_for_ordering.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140701095427050_add_trigger_for_messaging_receipts.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140701114842931_add_timestamps_back_to_messages.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140701144934637_adjust_constraints_of_receipts_table.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140706185141044_add_object_identifiers.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140707082435390_drop_tombstone_trigger.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140707175635814_add_is_draft_to_messages.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140708092626927_adjust_triggers_for_drafting.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140708154438053_change_insert_trigger_on_messages.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140709095453868_drop_track_sending_of_messages.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140715104949748_drop_message_index_table_add_message_index_column.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140717013309255_drop_is_draft_from_messages.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140717021208447_restore-lost-triggers.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140806143305965_add_created_at_to_conversations.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140820112730372_add_unique_constraint_to_message_recipient_status.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20140919115201707_create_synced_changes_table_and_decouple_models.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141002091849299_correct-track_inserts_of_events_delete.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141002175255465_making_version_a_required_field.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141002175510495_track_streams_and_stream_members_with_deleted_at_column.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141006140917614_add-client_id.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141006202908488_add_tombstone_duplicate_events_by_client_id.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141007110138268_client-id-indices.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141009125004707_min-max-synced-seq.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141009125010758_indices.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141027152445461_fix_invalid_identifier_types.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141105082802353_add_unread_fields_to_models.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141110114425514_remote_keyed_values.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20141124205020533_external_content.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150131122302694_add_indexes_for_unread.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150202170209118_flatten_transfer_flags_into_single_transfer_status_integer.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150207191203003_create_block_list.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150210133608257_adding_version_to_message_parts.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150316180034638_add-distinct-unqiue-flag-to-streams.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150319131356212_add-trigger-for-event-stream-id-update.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150330135300206_add_name_to_events_and_messages_tables.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150504150912979_add_transfer_status_to_event_content_parts.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150529142429027_add_type_to_streams_table.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/20150615160151227_add-distinct-triggers.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle/layer-client-messaging-schema.sql"
                    install_resource "LayerKit/LayerKit.embeddedframework/LayerKit.framework/Versions/A/Resources/layer-client-messaging-schema.bundle"
                    install_resource "SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundError.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundError@2x.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundErrorIcon.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundErrorIcon@2x.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundMessage.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundMessage@2x.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundSuccess.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundSuccess@2x.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundSuccessIcon.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundSuccessIcon@2x.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundWarning.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundWarning@2x.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundWarningIcon.png"
                    install_resource "TSMessages/Pod/Assets/NotificationBackgroundWarningIcon@2x.png"
                    install_resource "TSMessages/Pod/Assets/NotificationButtonBackground.png"
                    install_resource "TSMessages/Pod/Assets/NotificationButtonBackground@2x.png"
                    install_resource "TSMessages/Pod/Assets/TSMessagesDefaultDesign.json"
                    install_resource "VK-ios-sdk/VKSdkResources.bundle"
                    install_resource "${BUILT_PRODUCTS_DIR}/JSBadgeView.bundle"
                    install_resource "${BUILT_PRODUCTS_DIR}/UAAppReviewManager-iOS.bundle"
          
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi

CONFIG = .secure_files/config.yml

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  Configuration:"
	@echo "    dev_config                   Create development configuration file"
	@echo "    prod_config                  Create production configuration file"
	@echo ""
	@echo "  Setup:"
	@echo "    setup                        Setup ruby, flutter and helper environment"
	@echo "    create_key_properties        Create key.properties file for android"
	@echo "    ios_signing                  Setup ios signing"
	@echo "    export_options               Create export options plist file"
	@echo ""
	@echo "  Build:"
	@echo "    build_dev_android            Build development android apk and appbundle"
	@echo "    build_prod_android           Build production android apk and appbundle"
	@echo "    build_dev_ios                Build development ios ipa"
	@echo "    build_prod_ios               Build production ios ipa"
	@echo ""
	@echo "  Deploy:"
	@echo "    deploy_play_store            Deploy apk to play store"
	@echo "    deploy_test_flight           Deploy ipa to test flight"
	@echo ""
	@echo "  Upload:"
	@echo "    upload_apk_flutter_symbols   Upload flutter symbols for apk"
	@echo "    upload_aab_flutter_symbols   Upload flutter symbols for aab"
	@echo "    upload_dsyms                 Upload dSYMs to firebase"
	@echo ""
	@echo "  Keychain:"
	@echo "    keychain_create              Create temporary keychain"
	@echo "    keychain_delete              Delete temporary keychain"
	@echo "    keychain_list                List all keychains"
	@echo ""
	@echo "  Clean:"
	@echo "    clean_build                  Clean build files"
	@echo "    clean                        Clean dependencies"
	@echo ""
	@echo "  Dependencies:"
	@echo "    get                          Get dependencies"
	@echo "    get_gems                     Get ruby dependencies"
	@echo ""
	@echo "  Code Generation:"
	@echo "    gen                          Generate code"
	@echo ""
	@echo "  Versioning:"
	@echo "    build_bump                   Increment build number and push changes"
	@echo "    build_bump_prod              Increment build number and push changes for production"
	@echo "    version_bump                 Increment app version and push changes"

dev_config:
	sh ./scripts/environment/setup_config.sh -f development

prod_config:
	sh ./scripts/environment/setup_config.sh -f production

setup:
	sh ./scripts/environment/setup_ruby_env.sh
	sh ./scripts/environment/setup_helper_env.sh
	sh ./scripts/environment/setup_flutter_env.sh

create_key_properties:
	sh ./scripts/files/create_key_properties.sh \
		-s $$(yq eval ".android.key_properties.store_password" $(CONFIG)) \
		-k $$(yq eval ".android.key_properties.key_password" $(CONFIG)) \
		-a $$(yq eval ".android.key_properties.key_alias" $(CONFIG)) \
		-f $$(yq eval ".android.key_properties.store_file" $(CONFIG))

build_dev_android:
	sh ./scripts/build/build_apk.sh -f development
	sh ./scripts/build/build_appbundle.sh -f development
	sh ./scripts/files/move_android_builds.sh -f development

build_prod_android:
	sh ./scripts/build/build_apk.sh -f production
	sh ./scripts/build/build_appbundle.sh -f production
	sh ./scripts/files/move_android_builds.sh -f production

keychain_create:
	sh scripts/files/temp_keychain_create.sh

keychain_delete:
	sh scripts/files/temp_keychain_delete.sh

keychain_list:
	security list-keychain -d user

ios_signing:
	sh ./scripts/environment/setup_ios_sign_env.sh \
		-c $$(yq eval ".ios.signing.certificate" $(CONFIG)) \
		-p $$(yq eval ".ios.signing.certificate_password" $(CONFIG)) \
		-m $$(yq eval ".ios.signing.provisioning_profile" $(CONFIG))

export_options:
	sh ./scripts/files/create_export_options.sh \
		-p "$$(yq eval ".ios.signing.provisioning_profile_name" $(CONFIG))" \
		-c "$$(yq eval ".ios.signing.certificate_name" $(CONFIG))" \
		-b "$$(yq eval ".ios.signing.bundle_id" $(CONFIG))" \
		-t "$$(yq eval ".ios.signing.team_id" $(CONFIG))" \
		-m "app-store-connect" 

build_dev_ios:
	sh ./scripts/build/build_ipa.sh -f development
	sh ./scripts/files/move_ios_builds.sh -f development

build_prod_ios:
	sh ./scripts/build/build_ipa.sh -f production
	sh ./scripts/files/move_ios_builds.sh -f production

upload_apk_flutter_symbols:
	sh ./scripts/files/upload_flutter_symbols_firebase.sh \
		-g $$(yq eval ".google_service_account.firebase_developer.key" $(CONFIG)) \
		-b apk \
		-a $$(yq eval ".android.firebase_app_id" $(CONFIG))

upload_aab_flutter_symbols:
	sh ./scripts/files/upload_flutter_symbols_firebase.sh \
		-g $$(yq eval ".google_service_account.firebase_developer.key" $(CONFIG)) \
		-b aab \
		-a $$(yq eval ".android.firebase_app_id" $(CONFIG))

deploy_play_store:
	sh ./scripts/deploy/deploy_play_store.sh \
		-p $$(yq eval ".android.package_name" $(CONFIG)) \
		-j $$(yq eval ".google_service_account.fastlane_upload.key" $(CONFIG))

upload_dsyms:
	sh ./scripts/files/upload_dsyms.sh

deploy_test_flight:
	sh ./scripts/deploy/deploy_test_flight.sh \
		-b $$(yq eval ".ios.signing.bundle_id" $(CONFIG)) \
		-k $$(yq eval ".ios.appstoreconnect.api_key_id" $(CONFIG)) \
		-i $$(yq eval ".ios.appstoreconnect.api_issuer_id" $(CONFIG)) \
		-f $$(yq eval ".ios.appstoreconnect.api_key_file" $(CONFIG)) 

clean_build:
	sh ./scripts/files/clean.sh -b

clean:
	sh ./scripts/dependencies/clean.sh

get:
	sh ./scripts/dependencies/get.sh -f -i

get_gems:
	sh ./scripts/dependencies/get.sh -g

get_all:
	sh ./scripts/dependencies/get.sh -F

gen:
	sh ./scripts/files/code_gen.sh

build_bump:
	sh ./scripts/helper/increment_build_number.sh
	sh ./scripts/git/build_changes_push.sh -b -d -f development

build_bump_prod:
	sh ./scripts/helper/increment_build_number.sh
	sh ./scripts/git/build_changes_push.sh -b -d -f production

version_bump:
	sh ./scripts/helper/increment_app_version.sh patch
	sh ./scripts/git/version_changes_push.sh -d -f development
package mobile.backend;

import lime.system.System as LimeSystem;

/**
 * A storage class for mobile.
 * @author Mihai Alexandru (M.A. Jigsaw) and Lily (mcagabe19)
 */
class SUtil
{
	#if sys
	public static function getStorageDirectory(?force:Bool = false):String
	{
		var daPath:String = '';
		#if android
		if (!FileSystem.exists(LimeSystem.applicationStorageDirectory + 'storagetype.txt'))
			File.saveContent(LimeSystem.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);
		var curStorageType:String = File.getContent(LimeSystem.applicationStorageDirectory + 'storagetype.txt');
		daPath = force ? StorageType.fromStrForce(curStorageType) : StorageType.fromStr(curStorageType);
		daPath = haxe.io.Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#end

		return daPath;
	}

	public static function mkDirs(directory:String):Void
	{
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				try
				{
					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				}
				catch (e:haxe.Exception)
					trace('Error while creating folder. (${e.message}');
			}
		}
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json',
			fileData:String = 'You forgor to add somethin\' in yo code :3'):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/' + fileName + fileExtension, fileData);
			showPopUp(fileName + " file has been saved.", "Success!");
		}
		catch (e:haxe.Exception)
			trace('File couldn\'t be saved. (${e.message})');
	}

	#if android
	public static function doPermissionsShit():Void
	{
		if (!AndroidPermissions.getGrantedPermissions().contains(AndroidPermissions.READ_EXTERNAL_STORAGE)
			&& !AndroidPermissions.getGrantedPermissions().contains(AndroidPermissions.WRITE_EXTERNAL_STORAGE))
		{
			AndroidPermissions.requestPermission(AndroidPermissions.READ_EXTERNAL_STORAGE);
			AndroidPermissions.requestPermission(AndroidPermissions.WRITE_EXTERNAL_STORAGE);
			showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress Ok to see what happens',
				'Notice!');
			if (!AndroidEnvironment.isExternalStorageManager())
				AndroidSettings.requestSetting("android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
		}
		else
		{
			try
			{
				if (!FileSystem.exists(SUtil.getStorageDirectory()))
					FileSystem.createDirectory(SUtil.getStorageDirectory());
			}
			catch (e:Dynamic)
			{
				showPopUp("Please create folder to\n" + SUtil.getStorageDirectory(true) + "\nPress OK to close the game", "Error!");
				LimeSystem.exit(1);
			}
		}
	}

	public static function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);

		var lastStoragePath:String = StorageType.fromStrForce(mobile.options.MobileOptionsSubState.lastStorageType) + '/';
		/*var curStoragePath:String = StorageType.fromStrForce(File.getContent(LimeSystem.applicationStorageDirectory + 'storagetype.txt')) + '/';

		if (!FileSystem.exists(curStoragePath)) FileSystem.createDirectory(curStoragePath);
		for (smth in FileSystem.readDirectory(lastStoragePath))
		{
			trace(smth);
			trace(curStoragePath);
			trace(lastStoragePath);
			FileSystem.rename(lastStoragePath + smth, curStoragePath + smth);
			FileSystem.rename(lastStoragePath + smth, curStoragePath + smth);
		}*/

		try
		{
			Sys.command('rm', ['-rf', lastStoragePath]);
		}
		catch (e:haxe.Exception)
		{
			trace('Failed to remove last directory. (${e.message})');
		}
	}
	#end
	#end
	public static function showPopUp(message:String, title:String):Void
	{
		#if (!ios || !iphonesim)
		try
		{
			lime.app.Application.current.window.alert(message, title);
		}
		catch (e:Dynamic)
			trace('$title - $message');
		#else
		trace('$title - $message');
		#end
	}
}

#if android
enum abstract StorageType(String) from String to String
{
	final forcedPath = '/storage/emulated/0/';
	final packageNameLocal = 'com.shadowmario.psychengine';
	final fileLocal = 'PsychEngine';

	public static function fromStr(str:String):StorageType
	{
		final EXTERNAL_DATA = AndroidContext.getExternalFilesDir();
		final EXTERNAL_OBB = AndroidContext.getObbDir();
		final EXTERNAL_MEDIA = AndroidEnvironment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
		final EXTERNAL = AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');

		return switch (str)
		{
			case "EXTERNAL_DATA": EXTERNAL_DATA;
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: null;
		}
	}

	public static function fromStrForce(str:String):StorageType
	{
		final EXTERNAL_DATA = forcedPath + 'Android/data/' + packageNameLocal + '/files';
		final EXTERNAL_OBB = forcedPath + 'Android/obb/' + packageNameLocal;
		final EXTERNAL_MEDIA = forcedPath + 'Android/media/' + packageNameLocal;
		final EXTERNAL = forcedPath + '.' + fileLocal;

		return switch (str)
		{
			case "EXTERNAL_DATA": EXTERNAL_DATA;
			case "EXTERNAL_OBB": EXTERNAL_OBB;
			case "EXTERNAL_MEDIA": EXTERNAL_MEDIA;
			case "EXTERNAL": EXTERNAL;
			default: null;
		}
	}
}
#end

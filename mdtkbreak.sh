#!/usr/bin/env bash

# не думаю, что у тебя установлен figlet, поэтому я вывожу красивый арт с текстом через echo xd
# ещё, тебе не стоит задаваться вопрос о том, что значит mdtk <3

echo -e "             __ __   __     __                      __    \n.--------.--|  |  |_|  |--.|  |--.----.-----.---.-.|  |--.\n|        |  _  |   _|    < |  _  |   _|  -__|  _  ||    < \n|__|__|__|_____|____|__|__||_____|__| |_____|___._||__|__|\n==========================================================\nПРЕЖДЕ ЧЕМ ЗАПУСКАТЬ СКРИПТ НЕОБХОДИМО ВКЛЮЧИТЬ SSH!\nИНФОРМАЦИЯ ОБ ЭТОМ ЕСТЬ В РЕПОЗИТОРИИ\n"

md5() {
    printf "%s" "$1" | md5sum | awk '{print $1}'
}

echo -e "необходимо ввести айпи адрес и серинльный номер тв приставки.\nпосмотреть это можно в её настройках.\nглавное меню > все приложения > настройки\nоб устройстве > статус > IP-адрес + сериальный номер\n=========================================================="
read -p "айпи адрес : " ip 
read -p "серильный номер (SBxxxxxxxx) : " serial

# стадия генерации пароля. очень
serial_hash=$(md5 "$serial")
serial_combo=$(md5 "\$${serial_hash}+lkOk52KTfAsa73)")
root_pass=$(md5 "(root ${serial_combo}&")

LOCAL_TMP_APK=$(mktemp)

echo -e "\n\n==========================================================\nскачивание файлового менеджера (material files)\nhttps://f-droid.org/repo/me.zhanghai.android.files_39.apk"
curl -L https://f-droid.org/repo/me.zhanghai.android.files_39.apk -o "$LOCAL_TMP_APK"

export SSH_ASKPASS_REQUIRE=force
export SSH_ASKPASS=$(mktemp)
echo -e "#!/usr/bin/env bash\necho '$root_pass'" > "$SSH_ASKPASS"
chmod +x "$SSH_ASKPASS"

setsid -w ssh -oStrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-rsa root@$ip \
"cat > /storage/emulated/0/files.apk && pm install -r /storage/emulated/0/files.apk && exec sh -i" < "$LOCAL_TMP_APK"
echo -e "\n\nесли вылез Success, то значит всё прошло успешно!"

rm -f "$SSH_ASKPASS"
rm -f "$LOCAL_TMP_APK"

echo -e "\n\n\nготово! пароль от root : $root_pass\nесли ты захочешь подключиться к тв приставке позже, то нужно будет использовать команду ssh -oHostKeyAlgorithms=+ssh-rsa root@$ip\n(данный флаг нужен, ибо тв приставка содержит старую версию openssh)\n\nследующим шагом можно другие сайдлоуднуть приложения закинув .apk файл на тв приставку.\nнеобходимо поднять ftp сервер в material files и с другого устройства закинуть apk файл\n(ну, или можно модифицировать скрипт чтобы скачивался и устанавливался другой файл)\n\nесли скрипт не сработал или сработал слишком быстро (меньше 1-2 секунд), то значит вы сделали что-то не так\nпроверьте навсякий случай введён ли правильно ip адрес и серийный номер"

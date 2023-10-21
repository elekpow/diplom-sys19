
#  Дипломная работа по профессии «Системный администратор»

**Группа:** **SYS-19**  <br/> Игорь Левин

**период обучения:** 28 сентября 2022 — 30 октября 2023

---
Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю) 
---
* [Дипломный проект](#Дипломный-проект)
    * [Инфраструктура](#Инфраструктура-проекта)
---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

Так как прерываемая ВМ проработает не больше 24ч, после сдачи работы на проверку свяжитесь с вашим дипломным руководителем и договоритесь запустить инфраструктуру к указанному времени.

**Продвинутый вариант:** Вместо создания обычной ВМ, создайте Instance Groups с прерываемыми ВМ. После остановки работы ВМ, Instance Groups автоматически их запустит. Подробности в  [инструкции](https://cloud.yandex.ru/docs/compute/concepts/instance-groups/). 

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно
Не входит в минимальные требования. 

1. Для Zabbix можно реализовать разделение компонент - frontend, server, database. Frontend отдельной ВМ поместите в публичную подсеть, назначте публичный IP. Server поместите в приватную подсеть, настройте security group на разрешение трафика между frontend и server. Для Database используйте [Yandex Managed Service for PostgreSQL](https://cloud.yandex.com/en-ru/services/managed-postgresql). Разверните кластер из двух нод с автоматическим failover.
2. Вместо конкретных ВМ, которые входят в target group, можно создать [Instance Group](https://cloud.yandex.com/en/docs/compute/concepts/instance-groups/), для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
3. В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Zabbix, через filebeat. Можно использовать logstash тоже.
4. Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.

## Выполнение работы
На этом этапе вы непосредственно выполняете работу. При этом вы можете консультироваться с руководителем по поводу вопросов, требующих уточнения.

⚠️ В случае недоступности ресурсов Elastic для скачивания рекомендуется разворачивать сервисы с помощью docker контейнеров, основанных на официальных образах.

**Важно**: Ещё можно задавать вопросы по поводу того, как реализовать ту или иную функциональность. И руководитель определяет, правильно вы её реализовали или нет. Любые вопросы, которые не освещены в этом документе, стоит уточнять у руководителя. Если его требования и указания расходятся с указанными в этом документе, то приоритетны требования и указания руководителя.

## Критерии сдачи
1. Инфраструктура отвечает минимальным требованиям, описанным в [Задаче](#Задача).
2. Предоставлен доступ ко всем ресурсам, у которых предполагается веб-страница (сайт, Kibana, Zabbix).
3. Для ресурсов, к которым предоставить доступ проблематично, предоставлены скриншоты, команды, stdout, stderr, подтверждающие работу ресурса.
4. Работа оформлена в отдельном репозитории в GitHub или в [Google Docs](https://docs.google.com/), разрешён доступ по ссылке. 
5. Код размещён в репозитории в GitHub.
6. Работа оформлена так, чтобы были понятны ваши решения и компромиссы. 
7. Если использованы дополнительные репозитории, доступ к ним открыт. 

## Как правильно задавать вопросы дипломному руководителю
Что поможет решить большинство частых проблем:
1. Попробовать найти ответ сначала самостоятельно в интернете или в материалах курса и только после этого спрашивать у дипломного руководителя. Навык поиска ответов пригодится вам в профессиональной деятельности.
2. Если вопросов больше одного, присылайте их в виде нумерованного списка. Так дипломному руководителю будет проще отвечать на каждый из них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой покажите, где не получается. Программу для этого можно скачать [здесь](https://app.prntscr.com/ru/).

Что может стать источником проблем:
1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения дипломной работы на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители — работающие инженеры, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

---

## Дипломный проект
---

Начнем разработку отказоустойчивой инфраструктуры для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Для обеспечения безопасности доступ к серверам реалзом через сервер-бастион **("bastion-elvm")**, имеющий внешний ip-адрес и доступный 22 порт для подключения по ssh. В общей локальной сети находятся другие сервера: Zabbix, Kibana, Elasticsearch.


 начальная структура будет выглядеть так :

```
.
├── bastion-elvm.tf
├── metadata
│   ├── bastion.yml
│   ├── websrv.yml
├── network.tf
├── provider.tf
├── source
│   ├── index.html
├── target-group.tf
├── variables.tf
└── websrv-elvm.tf
```
Для развертывания идентичных веб серверов в файле **websrv-elvm.tf** приписываю необходимую конфигурацию.

настройки системы для серверов :

в проекте используется **Платформа Intel Ice Lake**, конфигурация задается параметром **platform_id = "${var.platform["v3"]}"** что соответсвует переменной **"standard-v3"** в файле **variables.tf**. Для отказоустойчивой работы для серверов **Elasticsearch** и **Kibana** выделено **8Гб** оперативной памяти.

```
  resources {
    core_fraction = 20 # производительность 20%
    cores  = 2 # процессор: 2 ядра
    memory = 2 # оперативная память 2 Гб
  }
  
  scheduling_policy {
    preemptible = true # прерываемая
  }
```

На каждом из серверов установен основной загрузочный диск размером 10Гб, с операционной системой **debian_10** , для **Zabbix-сервера** используется **debian_11** .

```
  boot_disk {
    initialize_params {
      image_id = "${var.images["debian_10"]}"
      type = "network-ssd"
      size = "10"
    }
  }

```

Две виртуальные машины **websrv-elvm-1** и **websrv-elvm-2** расположены в разных зонах, в переменных обозначены **"zone_a"** и **"zone_b"**. Переменны задаются в файле **variables.tf**

```
variable "zone_data" {
  type = map
  default = {
   "zone_a" = "ru-central1-a"
   "zone_b" = "ru-central1-b"
  }
}
```
Для развертывания веб-серверов в provisioner прописываем установку через terraform минимального набора приложений и необходимых конфигурационных файлов.
Так как понадобиться **zabbix-агент**, через параметр **runcmd** устанвливаю репозиторий **zabbix** и произвожуего усатновку. Также добавляю приветственную страницу веб сервера **./source/index.html**. 
Конфигурация zabbix-агента находиться в директории **./source** , можно перенести на удаленный сервер через terraform используя **provisioner** , который так же подключается к сереверам через **сервер-бастион**. 
Также прописываю ключ для авторизации по ssh. Перед тем как запустить резвертываение виртуальных машин, необходимо заупусить ssh-агент, который запомнит парольную фразу и позволит автоматически подключаться к серверам.
**подсказка сохранена в ./metadata/bastion.yml**  `cat ./metadata/bastion.yml | grep eval`

Теперь настраиваю балансировщик нагрузки: Создаю Target Group - "elvm-tg", в которую добавлю подсети веб-серверов , создаю backend group и HTTP router и конфигурирую load balancer. Порт 80 используемый веб сервером nginx. healthcheck c настройками:  timeout = "1s" и interval = "1s".

```
    healthcheck {
      timeout              = "1s"
      interval             = "1s"
      http_healthcheck {
        path               = "/"
      }
    }

```

вывод ip адреса load-balancer:
```
output "balancer_ip-elvm" {
  description = "ALB public IPs"
  value       = yandex_alb_load_balancer.elvm-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}
```

## Инфраструктура проекта


terraform apply -auto-approve

ansible-playbook -i ansible/inventory ansible/install.yml



1) Протестируйте сайт 

```
curl -v 51.250.47.212:80
```
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

2)  access.log, error.log nginx в Elasticsearch.

3) Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

terraform destroy -auto-approve


Структура проекта

```
.
├── ansible
│   ├── install.yml
│   ├── inventory
│   ├── roles
│   └── template
├── ansible.cfg
├── bastion-elvm.tf
├── elk-elvm.tf
├── metadata
│   ├── bastion.yml
│   └── servers.yml
├── network.tf
├── provider.tf
├── target-group.tf
├── variables.tf
├── websrv-elvm.tf
└── zabbix-elvm.tf
```

Ansible roles

```
ansible
├── roles
│   ├── bastion
│   ├── elasticsearch
│   ├── filebeat
│   ├── kibana
│   ├── nginx
│   ├── zabbix
│   └── zabbix-agent
├── install.yml
└── template
```



```
Outputs:

bastion-elvm = "158.160.45.111"
host_kibana-elvm = "158.160.34.141"
host_zabbix-elvm = "158.160.56.157"
ip_elvm-balancer = "51.250.46.167"
local_ip_elastic-elvm = "172.16.121.29"
local_ip_kibana-elvm = "172.16.121.20"
local_ip_websrv-elvm-1 = "172.16.121.33"
local_ip_websrv-elvm-2 = "172.16.122.6"
local_ip_zabbix-elvm = "172.16.121.21"
```

ip адрес бастион хоста `158.160.45.111`

Веб сервера находяться в приватной сети

```
local_ip_websrv-elvm-1 = "172.16.121.33"
local_ip_websrv-elvm-2 = "172.16.122.6"
```

подключаемся к серверам через бастион 

```
ssh -i ~/.ssh/id_ed25519 -J bastion@158.160.45.111 igor@kibana-elvm

```

Запускаем установку через ansible
```
ansible-playbook -i ansible/inventory ansible/install.yml
```

скрипт установки
```
---
- hosts: bastion-elvm ## bastion server
  become: yes
  remote_user: bastion
  roles:
    - bastion
- hosts: websrv-elvm ## web server
  become: yes
  remote_user: igor 
  roles:
    - nginx  
    - zabbix-agent
    - filebeat    
- hosts: elastic-elvm ## elastic server
  become: yes
  remote_user: igor
  roles:
    - elasticsearch    
- hosts: kibana-elvm ## kibana server
  become: yes
  remote_user: igor
  roles:
    - nginx   
    - kibana  
- hosts: zabbix-elvm ## zabbix server
  become: yes
  remote_user: igor
  roles:
    - nginx 
    - zabbix-agent    
    - zabbix

```


использую шаблон для автоматизации 

```
bastion-elvm:
  hosts:
    #bastion-elvm:  
websrv-elvm:
  hosts:
    #websrv-elvm-1:
    #websrv-elvm-2:  
  vars:
    ansible_python_interpreter: '/usr/bin/python3'
    ansible_ssh_user: 'igor'
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q bastion@#bastion-elvm"'    
elastic-elvm:
  hosts:
    #elastic-elvm:
  vars:
    ansible_python_interpreter: '/usr/bin/python3'
    ansible_ssh_user: 'igor'
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q bastion@#bastion-elvm"'        
kibana-elvm:
  hosts:
    #kibana-elvm:
  vars:
    ansible_python_interpreter: '/usr/bin/python3'
    ansible_ssh_user: 'igor'
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q bastion@#bastion-elvm"'        
zabbix-elvm:
  hosts:
    #zabbix-elvm:
  vars:
    ansible_python_interpreter: '/usr/bin/python3'
    ansible_ssh_user: 'igor'
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q bastion@#bastion-elvm"'   

```



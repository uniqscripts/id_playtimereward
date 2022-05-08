$(function () {

    function display(bool) {
        if (bool) {
            $("html").show();
        } else {
            $("html").hide();
        }
    }

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "show") {
            if (item.status == true) {
                $("html").fadeIn();
                display(true)
            } else {
                display(false)
            }
        }
    })

    window.addEventListener('message', function (event) {
        try {
            switch(event.data.action) {
                case 'howmuchhours':
                    if (event.data.value != null) howmuchhours.innerHTML = event.data.value;
                break;

                case 'whathour':
                    if (event.data.value != null) whathour.innerHTML = event.data.value;
                break;

                case 'whatminute':
                    if (event.data.value != null) whatminute.innerHTML = event.data.value;
                break;
            }
    } catch(err) {}
    });
})
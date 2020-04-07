let $d = $(document),
    $w = $(window),
    $b = $('body');

$(() => {
    function twoDigits(n) {
        return n < 10 ? '0'+n : n;
    }

    let s = io.connect('http://localhost:8080');
    let oldJ = [8888,8888,8888,8888,8888,8888,8888,8888,8888,8888,8888,8888,8888,8888];
    let oldS = ['8888','8888','8888','8888','8888','8888','8888'];

    s.on('judgments', data => {
        if (data.length == 0) {
            if (oldJ[0] != 9999 && oldJ[1] != 9999) {
                oldJ = [9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999,9999];
                for (let i = 1; i <= 12; i++) {
                    document.getElementById(`j_${i}`).innerHTML = 0;
                    document.getElementById(`j_${i}_p`).innerHTML = 0;
                }
                document.getElementById('j_13').innerHTML = '00.00%';
                document.getElementById('j_14').innerHTML = '50%';
            }
        } else {
            let gSum = data[0] + data[1] + data[2] + data[3] + data[4] + data[5];
            let lSum = data[6] + data[7] + data[8] + data[9] + data[10] + data[11];
            for (let i = 0; i < data.length; i++) {
                if (i == 12 && data[12] != oldJ[12]) {
                    let v = Number(data[12]).toFixed(2);
                    document.getElementById('j_13').innerHTML = (data[12] < 10 ? '0' : '') + v + '%';
                } else if (i == 13 && data[13] != oldJ[13]) {
                    document.getElementById('j_14').innerHTML = `${data[13]}%`;
                } else if (i < 6) {
                    if (data[i] != oldJ[i]) {
                        let v = data[i];
                        document.getElementById(`j_${i+1}`).innerHTML = v;
                    }
                    if (gSum > 0) {
                        let p = Math.round(100*data[i] / gSum);
                        document.getElementById(`j_${i+1}_p`).innerHTML = p;
                    } else {
                        document.getElementById(`j_${i+1}_p`).innerHTML = 0;
                    }
                } else if (i < 12) {
                    if (data[i] != oldJ[i]) {
                        let v = data[i];
                        document.getElementById(`j_${i+1}`).innerHTML = v;
                    }
                    if (lSum > 0) {
                        let p = Math.round(100*data[i] / lSum);
                        document.getElementById(`j_${i+1}_p`).innerHTML = p;
                    } else {
                        document.getElementById(`j_${i+1}_p`).innerHTML = 0;
                    }
                }
            }
            oldJ = data;
        }
    });

    s.on('songinfos', data => {
        if (data.length == 0) {
            if (oldS[0] != '9999' && oldS[1] != '9999') {
                oldS = ['9999','9999','9999','9999','9999','9999','9999','9999','9999'];
                document.getElementById('s_1').innerHTML = '';
                document.getElementById('s_2').innerHTML = '';
                document.getElementById('s_3').innerHTML = '(00:00)';
                for (let j = 0; j <= 5; ++j) {
                    $('#s_4').removeClass(`d_${j}`);    
                }
                document.getElementById('s_4').innerHTML = '-';
                document.getElementById('s_5').innerHTML = '(-)';
                document.getElementById('s_6').innerHTML = '(-)';
                document.getElementById('s_8').innerHTML = '(-)';
				document.getElementById(`sm_banner`).src = "img\\bn.png";
                s.emit('game', '');
            }
        } else {
            let iii = 0;
            for (let i = 0; i < data.length; i++) {
                if (data[i] != oldS[i]) {
                    iii++;
                    if (i == 2) {
                        let min = Math.floor(data[2] / 60);
                        let sec = data[2] % 60;
                        document.getElementById('s_3').innerHTML = `(${twoDigits(min)}:${twoDigits(sec)})`;
                    } else if (i == 3) {
                        document.getElementById('s_4').innerHTML = twoDigits(data[3]);
                    } else if (i == 6) {
                        for (let j = 0; j <= 5; ++j) {
                            $('#s_4').removeClass(`d_${j}`);    
                        }
                        $('#s_4').addClass(`d_${data[6]}`);
                    } else if (i == 8) {
                        if (document.getElementById(`sm_banner`)) {
							document.getElementById(`sm_banner`).src = `${data[8]}`.substring(1);
						}
                    } else {
                        if (document.getElementById(`s_${i+1}`)) {
							if (i==7){
								if ( data[i] != ''){
								document.getElementById(`s_${i+1}`).innerHTML = 'Modded by ' + data[i];	
								}else{
									document.getElementById(`s_${i+1}`).innerHTML = '-';	
								}
							}else{
								document.getElementById(`s_${i+1}`).innerHTML = data[i];
							}
                        }
                    }
                }
				
            }
            /*if (!data[5]) {
                document.getElementById('song-infos').style.backgroundImage = "url('/files/old/SgI-bg.png')";
                document.getElementById('song-infos-content').style.backgroundColor = 'transparent';
            }*/
            oldS = data;
            if (iii > 1) {
                s.emit('game', data[0] + ' - ' + data[1]);
            }
        }
    });

    $d.foundation();
});
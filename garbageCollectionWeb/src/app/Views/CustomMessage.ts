import { Message } from 'primeng/primeng';


export class CustomMessage {
    msgs: Message[] = [];
    clearMessages() {
        this.msgs = [];

    }
    showInfo(summaryParam, detailParam) {
        const message = { severity: 'info', summary: summaryParam, detail: detailParam };
        this.showMessage(message, 3000);
    }

    showWarn(summaryParam, detailParam) {
        const message = { severity: 'warn', summary: summaryParam, detail: detailParam };
        this.showMessage(message, 3000);
    }

    showError(summaryParam, detailParam) {

        const message = { severity: 'error', summary: summaryParam, detail: detailParam };
        this.showMessage(message, 3000);
    }
    showErrorF12() {

        let message = { severity: 'error', summary: 'Error', detail: 'Se ha presentado un Error' };
        this.showMessage(message, 3000);
        message = { severity: 'error', summary: 'Error', detail: 'Presione F12 para ver el registro' };
        this.showMessage(message, 3000);

    }

    showSuccess(summaryParam, detailParam) {

        const message = { severity: 'success', summary: summaryParam, detail: detailParam };
        this.showMessage(message, 3000);
    }

    showMessage(message, time) {
        this.msgs.push(message);
        setTimeout(() => {
            const index = this.msgs.indexOf(message);
            if (index > -1) {
                this.msgs.splice(index, 1);
            }

        }, time);
    }
}
